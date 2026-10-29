# Carapace completions
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'

if (( $+commands[carapace] )); then
  source <(carapace _carapace)
fi

# Enable precise duration measurement.
zmodload zsh/datetime

# Prevent notification floods: allow at most one notification every 5 seconds.
typeset -gF 6 _last_command_notify_epoch=0

# Runs immediately before a command starts.
_command_start() {
  typeset -gF 6 _cmd_start_epoch=$EPOCHREALTIME
  typeset -g _cmd_started="$(date '+%H:%M:%S')"
  typeset -g _cmd_text="$1"
  typeset -g _cmd_user="$(id -un)"
  typeset -g _cmd_shell_pid=$$
  typeset -g _cmd_tmpdir=""
  typeset -g _cmd_watcher_pid=""

  # Escape regex metacharacters so grep searches for the literal command text.
  typeset -g _cmd_regex
  _cmd_regex=$(printf '%s' "$_cmd_text" |
    sed 's/[][\\.^$*+?(){}|]/\\&/g')

  printf '\n\033[1;36mCOMMAND STARTED\033[0m\n'
  printf '\033[33mUser:       \033[0m%s\n' "$_cmd_user"
  printf '\033[33mCommand:    \033[0m%s\n' "$_cmd_text"
  printf '\033[33mStart time: \033[0m%s\n' "$_cmd_started"
  printf '\033[33mShell PID:  \033[0m%s\n' "$_cmd_shell_pid"

  # Send the only notification, at command start, subject to the cooldown.
  local -F 6 notify_now=$EPOCHREALTIME
  if (( $+commands[notify-send] )) &&
     (( notify_now - _last_command_notify_epoch >= 5 )); then
    _last_command_notify_epoch=$notify_now

    notify-send --app-name="zsh" --icon=utilities-terminal \
      "COMMAND STARTED" \
      "User: $_cmd_user
Command + parameters: $_cmd_text
Start time: $_cmd_started
Shell PID: $_cmd_shell_pid"
  fi

  # Save existing process IDs so they are not mistaken for the new command.
  _cmd_tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/zsh-command.XXXXXX") || return
  typeset -g _cmd_tmpdir

  local baseline_file="$_cmd_tmpdir/baseline_pids"
  local snapshot_file="$_cmd_tmpdir/snapshot"
  local pid_file="$_cmd_tmpdir/command_pid"
  local ready_file="$_cmd_tmpdir/ready"

  ps -auxww >| "$snapshot_file" 2>/dev/null
  sed -nE \
    '2,$s/^[[:space:]]*[^[:space:]]+[[:space:]]+([0-9]+)[[:space:]].*/\1/p' \
    "$snapshot_file" >| "$baseline_file"

  # Search for a new process whose command line matches the typed command.
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

          # Print the actual command PID in the COMMAND STARTED section.
          printf '\033[33mCommand PID:\033[0m %s\n' "$pid" \
            > /dev/tty 2>/dev/null
          exit 0
        fi
      done < <(
        grep -E -- "$_cmd_regex" "$snapshot_file" |
          sed -nE \
            's/^[[:space:]]*[^[:space:]]+[[:space:]]+([0-9]+)[[:space:]].*/\1/p'
      )

      sleep 0.01
    done

    # Built-ins such as cd do not have a separate command process.
    printf '\033[33mCommand PID:\033[0m not available\n' \
      > /dev/tty 2>/dev/null
  ) &!

  typeset -g _cmd_watcher_pid=$!
  : >| "$ready_file"
}

# Runs after a command finishes and sets the next prompt.
_command_end() {
  local exit_code=$?

  if [[ -n ${_cmd_start_epoch-} ]]; then
    local -F 6 end_epoch=$EPOCHREALTIME
    local -F 6 elapsed=$(( end_epoch - _cmd_start_epoch ))

    # Show the completion summary only for commands lasting at least 4 seconds.
    if (( elapsed >= 4 )); then
      local end_time="$(date '+%H:%M:%S')"
      local -i elapsed_seconds=$(( elapsed ))
      local duration

      duration=$(printf '%02d:%02d:%02d' \
        $(( elapsed_seconds / 3600 )) \
        $(( (elapsed_seconds % 3600) / 60 )) \
        $(( elapsed_seconds % 60 )))

      local result=SUCCESS
      (( exit_code == 0 )) || result=FAILED

      printf '\n\033[1;36m_________________\nEXECUTION INFO\033[0m\n'
      printf '\033[33mUser:      \033[0m%s\n' "$_cmd_user"
      printf '\033[33mCommand:   \033[0m%s\n' "$_cmd_text"
      printf '\033[33mStarted:   \033[0m%s\n' "$_cmd_started"
      printf '\033[33mEnded:     \033[0m%s\n' "$end_time"
      printf '\033[33mDuration:  \033[0m%s (hh:mm:ss)\n' "$duration"
      printf '\033[33mShell PID: \033[0m%s\n' "$_cmd_shell_pid"

      if (( exit_code == 0 )); then
        printf '\033[33mResult:    \033[32m%s (exit code %d)\033[0m\n' \
          "$result" "$exit_code"
      else
        printf '\033[33mResult:    \033[31m%s (exit code %d)\033[0m\n' \
          "$result" "$exit_code"
      fi

      printf '\033[1;36m_________________\033[0m\n'
    fi

    # Stop the watcher and remove its temporary files.
    if [[ -n ${_cmd_watcher_pid-} ]]; then
      kill "$_cmd_watcher_pid" 2>/dev/null
    fi
    if [[ -n ${_cmd_tmpdir-} ]]; then
      rm -rf -- "$_cmd_tmpdir"
    fi

    unset _cmd_start_epoch _cmd_started _cmd_text _cmd_user _cmd_regex
    unset _cmd_shell_pid _cmd_tmpdir _cmd_watcher_pid
  fi

  if (( exit_code == 0 )); then
    PROMPT='%~ ❯ '
  else
    PROMPT='%~ ✘ '"$exit_code"' '
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _command_start
add-zsh-hook precmd _command_end
