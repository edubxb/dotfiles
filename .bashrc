## if not running interactively, don't do anything ##
[[ -z "$PS1" ]] && return

## Bash-it ##
BASH_IT="${HOME}/.bash_it"
if [[ -d "${BASH_IT}" ]]; then
  export BASH_IT
  export PS2="| "
  source "${BASH_IT}/bash_it.sh"
fi

## Starship prompt ##
eval "$(starship init bash)"

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
# HISTIGNORE='&:[bf]g:cd:clear:exit:f[dp]:help?( *):history?(*):l[sl1]?( *):man?( *):pwd:task?(sh)?( *):tasksh *:timew?( *):* --help:* --version'
HISTIGNORE='&:[bf]g:cd:clear:exit:f[dp]:help?( *):history?(*):man?( *):pwd:task?(sh)?( *):tasksh *:timew?( *):* --help:* --version'
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
command -v time &> /dev/null && alias "time=command $(command -v time)"

## projects paths ##
export PROJECTS_PATH="${HOME}/Area51/personal:${HOME}/Area51/floss:${HOME}/Area51/work"

## fzf config ##
if command -v fzf &> /dev/null; then
  export FZF_DEFAULT_OPTS="--filepath-word --no-mouse --reverse \
                           --inline-info --tabstop=4 --prompt='❯ ' \
                           --color hl:208,hl+:208,fg:255,fg+:255,bg+:240,header:255 \
                           --color info:46,prompt:33,spinner:108,pointer:160,marker:255"
  export FZF_DEFAULT_COMMAND="fdfind --type f --exclude .git"
  export FZF_ALT_C_COMMAND="fdfind --type d --exclude .git"
  export FZF_CTRL_T_COMMAND="fdfind --exclude .git"
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

## adsf-vm ##
source "${HOME}/.asdf/asdf.sh"
source "${HOME}/.asdf/completions/asdf.bash"

# AWS cli v2 completion
complete -C "${HOME}/Apps/aws-cli/v2/current/bin/aws_completer" aws

## poetry ##
source <(poetry completions bash)

# GitHub cli ##
eval "$(gh completion -s bash)"

## travis ##
export TRAVIS_CONFIG_PATH="${CONFIG_PATH}/travis"

## ansible ##
export ANSIBLE_NOCOWS=1

## psql ##
export PSQLRC="${CONFIG_PATH}/psql/psqlrc"
export PGSERVICEFILE="${CONFIG_PATH}/psql/pg_service.conf"

## taskwarrior ##
export TASKRC="${CONFIG_PATH}/taskrc"
export VIT_DIR="${CONFIG_PATH}/vit"

## timewarrior ##
export TIMEWARRIORDB="${CONFIG_PATH}/timewarrior"

## go jira ##
eval "$(jira --completion-script-bash)"
export JIRA_EDITOR="${VISUAL}"

## navi ##
export NAVI_PATH="${CONFIG_PATH}/navi/cheats"

## k8s ##
export KUBECONFIG="${CONFIG_PATH}/kube/config"
source <(kubectl completion bash)
