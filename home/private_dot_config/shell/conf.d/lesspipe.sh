## colors for less, man, etc. ##
[[ -f "${CONFIG_PATH}/less/TERMCAP" ]] && source "${CONFIG_PATH}/less/TERMCAP"

## make less more friendly for non-text input files ##
if command -v lesspipe &> /dev/null; then
  eval "$(SHELL="/bin/sh" lesspipe)"
fi
