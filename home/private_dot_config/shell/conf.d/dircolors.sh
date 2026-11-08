## enable ls color support ##
if command -v dircolors &> /dev/null; then
  test -r "${CONFIG_PATH}/dircolors" && eval "$(dircolors -b ${CONFIG_PATH}/dircolors)" || eval "$(dircolors -b)"
fi
