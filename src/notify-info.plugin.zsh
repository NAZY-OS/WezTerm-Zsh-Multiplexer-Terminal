# Carapace completions
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'

if (( $+commands[carapace] )); then
  source <(carapace _carapace)
fi

# Enable precise timing
zmodload zsh/datetime

# Notification state:
# - Max 1 notification every 5 seconds
# - After 5 notifications in 30 seconds, ask to pause for 10 minutes
typeset -gF 6 _last_notify_time=0
typeset -ga _recent_notify_times=()
typeset -gi _pause_notifications_until=0

# Runs before a command starts
_command_preexec() {
  typeset -gF 6 _cmd_start_time=$EPOCHREALTIME
  typeset -g _cmd_start_time_str="$(date '+%H:%M:%S')"
  typeset -g _cmd_text="$1"
  typeset -g _cmd_user="$(id -un)"
  typeset -g _cmd_shell_pid=$$
  typeset -g _cmd_temp_dir=""
  typeset -g _cmd_watcher_pid=""

  # Escape regex special chars for literal matching
  typeset -g _cmd_regex
  _cmd_regex=$(printf '%s' "$_cmd_text" | sed 's/[][\\.^$*+?(){}|]/\\&/g')

  printf '\n\033[1;36mCOMMAND STARTED\033[0m\n'
  printf '\033[33mUser:       \033[0m%s\n' "$_cmd_user"
  printf '\033[33mCommand:    \033[0m%s\n' "$_cmd_text"
  printf '\033[33mStart time: \033[0m%s\n' "$_cmd_start_time_str"
  printf '\033[33mShell PID:  \033[0m%s\n' "$_cmd_shell_pid"

  # Create temp dir for tracking
  _cmd_temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/zsh-command.XXXXXX") || return
  typeset -g _cmd_temp_dir

  local baseline_file="$_cmd_temp_dir/baseline_pids"
  local snapshot_file="$_cmd_temp_dir/process_snapshot"
  local pid_file="$_cmd_temp_dir/command_pid"
  local ready_file="$_cmd_temp_dir/ready"

  # Get baseline of running processes
  ps -auxww >| "$snapshot_file" 2>/dev/null
  sed -nE '2,$s/^[[:space:]]*[^[:space:]]+[[:space:]]+([0-9]+)[[:space:]].*/\1/p' "$snapshot_file" >| "$baseline_file"

  # Watch for new process matching our command
  (
    while [[ ! -e "$ready_file" ]]; do
      sleep 0.01
    done

    local i pid
    for (( i = 0; i < 100; i++ )); do
      ps -auxww >| "$snapshot_file" 2>/dev/null

      while IFS= read -r pid; do
        [[ -z "$pid" ]] && continue

        if ! grep -qxF "$pid" "$baseline_file" 2>/dev/null; then
          print -r -- "$pid" >| "$pid_file"
          printf '\033[33mCommand PID:\033[0m %s\n' "$pid" > /dev/tty 2>/dev/null
          exit 0
        fi
      done < <(
        grep -E -- "$_cmd_regex" "$snapshot_file" |
          sed -nE 's/^[[:space:]]*[^[:space:]]+[[:space:]]+([0-9]+)[[:space:]].*/\1/p'
      )

      sleep 0.01
    done

    # Built-ins like 'cd' don't have separate processes
    printf '\033[33mCommand PID:\033[0m not available\n' > /dev/tty 2>/dev/null
  ) &!

  typeset -g _cmd_watcher_pid=$!
  : >| "$ready_file"
}

# Runs after a command finishes
_command_postexec() {
  local exit_code=$?

  if [[ -n ${_cmd_start_time-} ]]; then
    local -F 6 end_time=$EPOCHREALTIME
    local -F 6 elapsed=$(( end_time - _cmd_start_time ))

    # Only show summary for commands taking ≥3 seconds
    if (( elapsed >= 3 )); then
      local end_time_str="$(date '+%H:%M:%S')"
      local -i elapsed_seconds=$(( elapsed ))
      local duration

      duration=$(printf '%02d:%02d:%02d' \
        $(( elapsed_seconds / 3600 )) \
        $(( (elapsed_seconds % 3600) / 60 )) \
        $(( elapsed_seconds % 60 )))

      local result="SUCCESS"
      (( exit_code != 0 )) && result="FAILED"

      printf '\n\033[1;36m_________________\nEXECUTION INFO\033[0m\n'
      printf '\033[33mUser:      \033[0m%s\n' "$_cmd_user"
      printf '\033[33mCommand:   \033[0m%s\n' "$_cmd_text"
      printf '\033[33mTime:      \033[0m%s → %s | Duration: %s\n' \
        "$_cmd_start_time_str" "$end_time_str" "$duration"
      printf '\033[33mShell PID: \033[0m%s\n' "$_cmd_shell_pid"

      if (( exit_code == 0 )); then
        printf '\033[33mResult:    \033[32mSUCCESS (exit code %d)\033[0m\n' "$exit_code"
      else
        printf '\033[33mResult:    \033[31mFAILED (exit code %d)\033[0m\n' "$exit_code"
        # Play 2 bell sounds for errors
        printf '\a\a'
      fi

      printf '\033[1;36m_________________\033[0m\n'

      # Notification handling
      local current_time=$EPOCHSECONDS

      if (( current_time >= _pause_notifications_until )); then
        # Keep only recent notifications (last 30 seconds)
        local -a recent_times=()
        local t

        for t in "${_recent_notify_times[@]}"; do
          (( current_time - t < 30 )) && recent_times+=("$t")
        done
        _recent_notify_times=("${recent_times[@]}")

        # Check for notification flood
        if (( ${#_recent_notify_times[@]} >= 5 )); then
          printf '\nPossible notification flood detected. '
          if read -q "reply?Pause notifications for 10 minutes? [y/N] "; then
            _pause_notifications_until=$(( current_time + 600 ))
            _recent_notify_times=()
            printf '\nNotifications paused for 10 minutes.\n'
          else
            _recent_notify_times=()
            printf '\nNotifications continuing.\n'
          fi
          print
        fi

        # Send notification if cooldown passed
        if (( current_time >= _pause_notifications_until )) &&
           (( $+commands[notify-send] )) &&
           (( current_time - _last_notify_time >= 5 )); then
          _last_notify_time=$current_time
          _recent_notify_times+=("$current_time")

          notify-send --app-name="zsh" --icon=utilities-terminal \
            --expire-time=0 \
            "COMMAND $result" \
            "Command: $_cmd_text
Time: $_cmd_start_time_str → $end_time_str
Duration: $duration
Exit code: $exit_code"
        fi
      fi
    fi

    # Clean up watcher and temp files
    if [[ -n ${_cmd_watcher_pid-} ]]; then
      kill "$_cmd_watcher_pid" 2>/dev/null
    fi
    if [[ -n ${_cmd_temp_dir-} ]]; then
      rm -rf -- "$_cmd_temp_dir"
    fi

    # Clear command tracking variables
    unset _cmd_start_time _cmd_start_time_str _cmd_text _cmd_user _cmd_regex
    unset _cmd_shell_pid _cmd_temp_dir _cmd_watcher_pid
  fi

  # Set prompt based on exit status
  if (( exit_code == 0 )); then
    PROMPT='%~ ❯ '
  else
    PROMPT='%~ ✘ '"$exit_code"' '
  fi
}

# Keybindings
# Ctrl+T: Show current time in ZLE message area
_show_current_time() {
  zle -M "$(date '+%H:%M:%S')"
}
zle -N _show_current_time
bindkey '^T' _show_current_time

# Alt+H: Run htop then return to command line
_run_htop() {
  zle -I
  command htop
  zle redisplay
}
zle -N _run_htop
bindkey '\eh' _run_htop

# Alt+Left/Right: Move by word
bindkey '\eb' backward-word
bindkey '\e[1;3D' backward-word
bindkey '\ef' forward-word
bindkey '\e[1;3C' forward-word

# Register hooks
autoload -Uz add-zsh-hook
add-zsh-hook preexec _command_preexec
add-zsh-hook precmd _command_postexec
