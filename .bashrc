## if not running interactively, don't do anything ##
[[ -z "$PS1" ]] && return

## VTE script ##
[[ "${TILIX_ID}" ]] && source /etc/profile.d/vte-2.91.sh

## Bash-it ##
export BASH_IT="${HOME}/.bash_it"

if [[ -d "${BASH_IT}" ]]; then
  export BASH_IT_THEME='powerline-multiline'
  export BATTERY_AC_CHAR=''
  export SCM_GIT_SHOW_REMOTE_INFO='true'
  export POWERLINE_SCM_GIT_CHAR=' '
  export POWERLINE_LEFT_SEPARATOR=''
  export POWERLINE_RIGHT_SEPARATOR=''
  export POWERLINE_PROMPT_USER_INFO_MODE='sudo'
  export POWERLINE_LEFT_PROMPT='cwd scm python_venv'
  export POWERLINE_RIGHT_PROMPT='clock battery user_info'

  source "${BASH_IT}/bash_it.sh"
fi

## Bash completion ##
source "${HOME}/.travis/travis.sh"
source <(awless completion bash)
source <(env _PIPENV_COMPLETE="source-bash" pipenv)

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
export EDITOR="nvim"
export VISUAL="nvim-qt --nofork"
# export VISUAL="nvr --remote-wait"
# export NVIM_LISTEN_ADDRESS="/tmp/neovim.socket"
export PAGER="less"
export LESS="-F -R -X"

## disable flow control key binding ##
stty -ixon

## tabs expanded to 4 spaces ##
tabs -4

## colors for less, man, etc. ##
[[ -f "${HOME}/.LESS_TERMCAP" ]] && source "${HOME}/.LESS_TERMCAP"

## make less more friendly for non-text input files ##
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL="/bin/sh" lesspipe)"

## enable ls color support ##
if [[ -x /usr/bin/dircolors ]]; then
  test -r "${HOME}/.dircolors" && eval "$(dircolors -b ${HOME}/.dircolors)" || eval "$(dircolors -b)"
fi

## host-dependent config ##
[[ -f "${HOME}/.bashrc_$(hostname -s)" ]] && source "${HOME}/.bashrc_$(hostname -s)"

## aliases & functions ##
[[ -f "${HOME}/.bash_functions" ]] && source "${HOME}/.bash_functions"
[[ -f "${HOME}/.bash_aliases" ]] && source "${HOME}/.bash_aliases"

## use time command if installed ##
which time &> /dev/null
[[ "$?" -eq 0 ]] && alias "time=command $(which time)"

## direnv ##
which direnv &> /dev/null
[[ "$?" -eq 0 ]] && eval "$(direnv hook bash)"

## fzf config ##
which fzf &> /dev/null
if [[ "$?" -eq 0 ]]; then
  source "${HOME}/.fzf.bash"
  export FZF_DEFAULT_OPTS="--reverse --inline-info --tabstop=4 --prompt='❯ '"
  export FZF_DEFAULT_COMMAND="rg --files"
  export FZF_ALT_C_COMMAND="bfs -type d -nohidden"
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
fi
