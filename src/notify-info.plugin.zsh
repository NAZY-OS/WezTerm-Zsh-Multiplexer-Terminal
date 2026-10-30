# Carapace completions
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'

if (( $+commands[carapace] )); then
  source <(carapace _carapace)
fi

# Enable high-resolution elapsed-time measurement.
zmodload zsh/datetime

# Notification state.
# - Send no more than one notification every 5 seconds.
# - After 5 notifications in 30 seconds, ask whether to pause for 10 minutes.
typeset -gF 6 _cmd_notify_last_epoch=0
typeset -ga _cmd_notify_times=()
typeset -gi _cmd_notifications_paused_until=0

# Runs immediately before an external command or widget command starts.
_command_start() {
  typeset -gF 6 _cmd_start_epoch=$EPOCHREALTIME
  typeset -g _cmd_started_at="$(date '+%H:%M:%S')"
  typeset -g _cmd_text="${1-}"
  typeset -g _cmd_user="$(id -un)"
  typeset -g _cmd_shell_pid=$$

  printf '\n\033[1;36mCOMMAND STARTED\033[0m\n'
  printf '\033[33mUser:       \033[0m%s\n' "$_cmd_user"
  printf '\033[33mCommand:    \033[0m%s\n' "$_cmd_text"
  printf '\033[33mStart time: \033[0m%s\n' "$_cmd_started_at"
  printf '\033[33mShell PID:  \033[0m%s\n' "$_cmd_shell_pid"
}

# Runs before the next prompt is displayed.
_command_end() {
  # Capture this before running any other command.
  local exit_code=$?

  if [[ -n ${_cmd_start_epoch-} ]]; then
    local -F 6 end_epoch=$EPOCHREALTIME
    local -F 6 elapsed=$(( end_epoch - _cmd_start_epoch ))

    # Print a summary and consider a notification only for commands
    # that ran for at least 3 seconds.
    if (( elapsed >= 3 )); then
      local ended_at="$(date '+%H:%M:%S')"
      local -i elapsed_seconds=$(( elapsed ))
      local duration
      local result=SUCCESS

      (( exit_code == 0 )) || result=FAILED

      duration=$(printf '%02d:%02d:%02d' \
        $(( elapsed_seconds / 3600 )) \
        $(( (elapsed_seconds % 3600) / 60 )) \
        $(( elapsed_seconds % 60 )))

      printf '\n\033[1;36m_________________\nEXECUTION INFO\033[0m\n'
      printf '\033[33mUser:      \033[0m%s\n' "$_cmd_user"
      printf '\033[33mCommand:   \033[0m%s\n' "$_cmd_text"
      printf '\033[33mTime:      \033[0m%s → %s | Duration: %s\n' \
        "$_cmd_started_at" "$ended_at" "$duration"
      printf '\033[33mShell PID: \033[0m%s\n' "$_cmd_shell_pid"

      if (( exit_code == 0 )); then
        printf '\033[33mResult:    \033[32mSUCCESS (exit code %d)\033[0m\n' \
          "$exit_code"
      else
        printf '\033[33mResult:    \033[31mFAILED (exit code %d)\033[0m\n' \
          "$exit_code"
      fi

      printf '\033[1;36m_________________\033[0m\n'

      local -i now=$EPOCHSECONDS

      if (( now >= _cmd_notifications_paused_until )); then
        # Keep only notification timestamps from the last 30 seconds.
        local -a recent_times=()
        local timestamp

        for timestamp in "${_cmd_notify_times[@]}"; do
          (( now - timestamp < 30 )) && recent_times+=("$timestamp")
        done
        _cmd_notify_times=("${recent_times[@]}")

        # Prompt when the fifth notification in the current 30-second
        # window is reached. Reset the window either way to avoid repeated
        # prompts from the same burst.
        if (( ${#_cmd_notify_times[@]} >= 4 )); then
          printf '\nPossible notification flood detected. '
          if read -q 'reply?Pause notifications for 10 minutes? [y/N] '; then
            _cmd_notifications_paused_until=$(( now + 600 ))
            _cmd_notify_times=()
            printf '\nNotifications paused for 10 minutes.\n'
          else
            _cmd_notify_times=()
            printf '\nNotifications will continue.\n'
          fi
          print
        fi

        # Check the cooldown after the prompt: the user may have chosen
        # to pause notifications.
        if (( now >= _cmd_notifications_paused_until )) &&
           (( $+commands[notify-send] )) &&
           (( now - _cmd_notify_last_epoch >= 5 )); then
          _cmd_notify_last_epoch=$now
          _cmd_notify_times+=("$now")

          notify-send \
            --app-name='zsh' \
            --icon=utilities-terminal \
            --expire-time=0 \
            "COMMAND $result" \
            "Command: $_cmd_text
Time: $_cmd_started_at → $ended_at
Duration: $duration
Exit code: $exit_code"
        fi
      fi
    fi

    unset _cmd_start_epoch _cmd_started_at _cmd_text
    unset _cmd_user _cmd_shell_pid
  fi

  # Set the prompt to show the previous command's status.
  if (( exit_code == 0 )); then
    PROMPT='%~ ❯ '
  else
    PROMPT='%~ ✘ '"$exit_code"' '
  fi
}

# Ctrl+T: show the current time in the ZLE message area.
_show_current_time() {
  zle -M "$(date '+%H:%M:%S')"
}
zle -N _show_current_time
bindkey '^T' _show_current_time

# Alt+H: run htop, then return to the command line.
_run_htop() {
  zle -I
  command htop
  zle redisplay
}
zle -N _run_htop
bindkey '\eh' _run_htop

# Alt+Left/Right: move by word.
bindkey '\eb' backward-word
bindkey '\e[1;3D' backward-word
bindkey '\ef' forward-word
bindkey '\e[1;3C' forward-word

autoload -Uz add-zsh-hook
add-zsh-hook preexec _command_start
add-zsh-hook precmd _command_end
