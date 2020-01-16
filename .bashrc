## if not running interactively, don't do anything ##
[[ -z "$PS1" ]] && return

## libVTE script ##
[[ -f /etc/profile.d/vte-2.91.sh ]] && source /etc/profile.d/vte-2.91.sh

## Tilix VTE script ##
[[ -n "${TILIX_ID}" ]] && TILIX_SILENT=1 source /usr/share/tilix/scripts/tilix_int.sh

## Bash-it ##
export BASH_IT="${HOME}/.bash_it"

if [[ -d "${BASH_IT}" ]]; then
  export PS2="| "
  export BASH_IT_THEME='powerline-multiline'
  export BATTERY_AC_CHAR=''
  export SCM_GIT_SHOW_REMOTE_INFO='true'
  export POWERLINE_SCM_GIT_CHAR=' '
  export POWERLINE_PYTHON_VENV_CHAR='py:'
  export POWERLINE_LEFT_SEPARATOR=''
  export POWERLINE_RIGHT_SEPARATOR=''
  export POWERLINE_LEFT_END=''
  export POWERLINE_RIGHT_END=''
  export POWERLINE_AWS_PROFILE_CHAR=' '
  export POWERLINE_PROMPT_USER_INFO_MODE='sudo'
  export POWERLINE_LEFT_PROMPT='cwd scm'
  export POWERLINE_RIGHT_PROMPT='aws_profile python_venv clock battery user_info'

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
shopt -s dirspell
shopt -s extglob
shopt -s globstar
shopt -s histappend
shopt -s hostcomplete
shopt -s lithist

## Bash history ##
HISTCONTROL='ignoreboth:erasedups'
HISTFILESIZE=3000
HISTIGNORE='&:[bf]g:cd:clear:exit:fd:help:history*:l[sl1]*:man*:pwd:task*'
HISTSIZE=1000
HISTTIMEFORMAT='%F %T  '

## edit & view ##
export EDITOR="nvim"
export VISUAL="nvim-gtk --no-fork"
export PAGER="less"
export LESS="-F -R -X -x1,5"

## Config paths ##
CONFIG_PATH="${HOME}/.config"
BASH_CONFIG_PATH="${CONFIG_PATH}/bash"

## colors for less, man, etc. ##
[[ -f "${CONFIG_PATH}/less/TERMCAP" ]] && source "${CONFIG_PATH}/less/TERMCAP"

## make less more friendly for non-text input files ##
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL="/bin/sh" lesspipe)"

## enable ls color support ##
if [[ -x /usr/bin/dircolors ]]; then
  test -r "${CONFIG_PATH}/dircolors" && eval "$(dircolors -b ${CONFIG_PATH}/dircolors)" || eval "$(dircolors -b)"
fi

## host-dependent config ##
[[ -f "${BASH_CONFIG_PATH}/bashrc_$(hostname -s)" ]] && source "${BASH_CONFIG_PATH}/bashrc_$(hostname -s)"

## aliases & functions ##
[[ -f "${BASH_CONFIG_PATH}/aliases" ]] && source "${BASH_CONFIG_PATH}/aliases"
[[ -f "${BASH_CONFIG_PATH}/functions" ]] && source "${BASH_CONFIG_PATH}/functions"

## use time command if installed ##
which time &> /dev/null && alias "time=command $(which time)"

## projects paths ##
export PROJECTS_PATH="${HOME}/Area51/personal:${HOME}/Area51/floss:${HOME}/Area51/work"

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

## ripgrep ##
export RIPGREP_CONFIG_PATH="${CONFIG_PATH}/ripgrep"

## httpie ##
export HTTPIE_CONFIG_DIR="${CONFIG_PATH}/httpie"

## gitin ##
export GITIN_HIDEHELP=true
export GITIN_LINESIZE=20
export GITIN_SEARCHMODE=fuzzy

## AWS ##
export AWS_DEFAULT_REGION="eu-west-1"
export AWS_DEFAULT_OUTPUT="text"
export AWS_CONFIG_FILE="${CONFIG_PATH}/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="${CONFIG_PATH}/aws/credentials"

## hub ##
export GITHUB_PROTOCOL=ssh

## travis ##
export TRAVIS_CONFIG_PATH="${CONFIG_PATH}/travis"

## ansible ##
export ANSIBLE_NOCOWS=1

## psql ##
export PSQLRC="${CONFIG_PATH}/psql/psqlrc"
export PGSERVICEFILE="${CONFIG_PATH}/psql/pg_service.conf"

## taskwarrior ##
export TASKRC="${CONFIG_PATH}/taskrc"

## go jira ##
eval "$(jira --completion-script-bash)"
export JIRA_EDITOR="${VISUAL}"
