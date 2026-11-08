## current shell ##
if [[ -n "${ZSH_VERSION:-}" ]]; then
  CURRENT_SHELL=zsh
elif [[ -n "${BASH_VERSION:-}" ]]; then
  CURRENT_SHELL=bash
else
  return 0
fi

## config paths ##
CONFIG_PATH="${XDG_CONFIG_HOME:-${HOME}/.config}"
SHELL_CONFIG_PATH="${CONFIG_PATH}/shell"

## terminal defaults ##
stty -ixon
tabs -4

## edit & view ##
export NVIM_APPNAME="lazyvim"
export EDITOR="nvim"
export PAGER="less"
export LESS="-F -R -X -x1,5"

## shared paths ##
export PROJECTS_ROOT="${HOME}/Area51"
if [[ -d "${PROJECTS_ROOT}" ]]; then
  PROJECTS_PATH="$(find "${PROJECTS_ROOT}" -mindepth 1 -maxdepth 1 -type d -print | sort | paste -sd:)"
else
  PROJECTS_PATH=""
fi
export PROJECTS_PATH
export RIPGREP_CONFIG_PATH="${CONFIG_PATH}/ripgrep"
