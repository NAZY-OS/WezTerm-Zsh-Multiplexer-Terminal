# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set up the prompt

autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=5000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

source /home/vuser01/git/tmux-zsh/notify-info.plugin.zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
# oder
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Harmonische Terminalfarben
typeset -g _C_RESET=$'\033[0m'
typeset -g _C_PURPLE=$'\033[38;5;141m'
typeset -g _C_ORANGE=$'\033[38;5;208m'
typeset -g _C_GREEN=$'\033[38;5;114m'
typeset -g _C_RED=$'\033[38;5;203m'
typeset -g _C_DIM=$'\033[38;5;245m'

function zle-line-finish() {
  if [[ $? -eq 0 ]]; then
    echo -e "\a"  # Success Signal: Piepton
  else
    echo -e "\a\a"  #Error Signal: Doppeltone
  fi
}
zle -N zle-line-finish


# Farben definieren
autoload -U colors && colors
local red="%F{red}"
local green="%F{green}"
local yellow="%F{yellow}"
local blue="%F{blue}"
local purple="%F{purple}"
local orange="%F{orange}"
local reset="%f"

# PS1: Kompakte, farbige Eingabezeile
PROMPT='
${red}%n@%m${reset} ${blue}%~${reset}
${purple}%T${reset} ${orange}%D{%d.%m.%y}${reset}
${green}✓${reset} '

# PS2: Fortsetzungszeile (mehrzeilig)
PS2='${yellow}...>${reset} '

# PS3: Auswahlmenü (z. B. für `select`)
PS3='${purple}Auswahl:${reset} '

# PS4: Debug-Ausgabe (für `set -x`)
PS4='${red}+${reset} ${blue}%x:%l${reset} '
