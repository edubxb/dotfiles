## atuin ##
if command -v atuin &> /dev/null; then
  export ATUIN_CONFIG_DIR="${CONFIG_PATH}/atuin"
  eval "$(atuin init "${CURRENT_SHELL}" --disable-up-arrow)"
fi
