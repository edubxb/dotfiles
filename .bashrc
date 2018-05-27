## if not running interactively, don't do anything ##
[[ -z "$PS1" ]] && return

## Tilix VTE script ##
[[ -n "${TILIX_ID}" ]] && TILIX_SILENT=1 source /usr/share/tilix/scripts/tilix_int.sh

## override travis config path ##
export TRAVIS_CONFIG_PATH="${HOME}/.config/travis"

## Bash-it ##
export BASH_IT="${HOME}/.bash_it"

if [[ -d "${BASH_IT}" ]]; then
  export BASH_IT_THEME='powerline-multiline'
  export BATTERY_AC_CHAR=''
  export SCM_GIT_SHOW_REMOTE_INFO='true'
  export POWERLINE_SCM_GIT_CHAR=' '
  export POWERLINE_PYTHON_VENV_CHAR='py:'
  export POWERLINE_LEFT_SEPARATOR=''
  export POWERLINE_RIGHT_SEPARATOR=''
  export POWERLINE_LEFT_END=''
  export POWERLINE_RIGHT_END=''
  export POWERLINE_PROMPT_USER_INFO_MODE='sudo'
  export POWERLINE_LEFT_PROMPT='cwd scm'
  export POWERLINE_RIGHT_PROMPT='python_venv clock user_info'

  source "${BASH_IT}/bash_it.sh"
fi

## disable flow control key binding ##
stty -ixon

## tabs expanded to 4 spaces ##
tabs -4

## Bash options ##
shopt -s autocd
shopt -s cdspell
shopt -s checkjobs
shopt -s checkwinsize
shopt -s cmdhist
shopt -s direxpand
shopt -s extglob
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
export EDITOR="nvim"
export VISUAL="nvim-gtk"
export PAGER="less"
export LESS="-F -R -X -x1,5"

## colors for less, man, etc. ##
[[ -f "${HOME}/.LESS_TERMCAP" ]] && source "${HOME}/.LESS_TERMCAP"

## make less more friendly for non-text input files ##
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL="/bin/sh" lesspipe)"

## enable ls color support ##
if [[ -x /usr/bin/dircolors ]]; then
  test -r "${HOME}/.dircolors" && eval "$(dircolors -b ${HOME}/.dircolors)" || eval "$(dircolors -b)"
fi

## Bash config path ##
CONFIG_PATH="${HOME}/.config/bash"

## host-dependent config ##
[[ -f "${CONFIG_PATH}/bashrc_$(hostname -s)" ]] && source "${CONFIG_PATH}/bashrc_$(hostname -s)"

## aliases & functions ##
[[ -f "${CONFIG_PATH}/aliases" ]] && source "${CONFIG_PATH}/aliases"
[[ -f "${CONFIG_PATH}/functions" ]] && source "${CONFIG_PATH}/functions"

## use time command if installed ##
which time &> /dev/null && alias "time=command $(which time)"

## fzf config ##
if which fzf &> /dev/null; then
  export FZF_DEFAULT_OPTS="--filepath-word --no-mouse --reverse \
                           --inline-info --tabstop=4 --prompt='❯ ' \
                           --color hl:208,hl+:208,fg:255,fg+:255,bg+:240,header:255 \
                           --color info:46,prompt:33,spinner:108,pointer:160,marker:255"
  export FZF_DEFAULT_COMMAND="fd --type f --exclude .git"
  export FZF_ALT_C_COMMAND="fd --type d --exclude .git"
  export FZF_CTRL_T_COMMAND="fd --exclude .git"
fi

export PROJECTS_PATH="${HOME}/Area51/personal:${HOME}/Area51/floss:${HOME}/Area51/work"
