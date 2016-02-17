## if not running interactively, don't do anything ##
[ -z "$PS1" ] && return

## Bash programmable completion ##
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

## Bash It ##
export BASH_IT=$HOME/.bash_it

if [[ -d "${BASH_IT}" ]]; then
  export BASH_IT_THEME='powerline-multiline'
  export POWERLINE_PROMPT_USER_INFO_MODE="sudo"
  export POWERLINE_LEFT_PROMPT="cwd scm"
  export POWERLINE_RIGHT_PROMPT="python_venv clock battery user_info"

  . "${BASH_IT}/bash_it.sh"
fi

## disable flow control shortcut ##
stty -ixon

## Bash options ##
shopt -s autocd
shopt -s cdspell
shopt -s checkjobs
shopt -s checkwinsize
shopt -s cmdhist
shopt -s direxpand
shopt -s dirspell
shopt -s globstar
shopt -s histappend
shopt -s hostcomplete
shopt -s lithist

## Bash history ##
HISTCONTROL='ignoreboth:erasedups'
HISTSIZE=1000
HISTFILESIZE=3000
HISTTIMEFORMAT='%F %T  '

## edit & view ##
export NVIM_TUI_ENABLE_TRUE_COLOR=1
export EDITOR=nvim
export PAGER="less"
export LESS="-F -X -R"

## tabs expanded to 4 spaces ##
tabs -4

## use colors for less, man, etc. ##
[[ -f ~/.LESS_TERMCAP ]] && . ~/.LESS_TERMCAP

## make less more friendly for non-text input files ##
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

## enable ls color support ##
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

## local config ##
if [ -f "${HOME}/.bashrc_local" ]; then
  . "${HOME}/.bashrc_local"
fi

## aliases ##
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
