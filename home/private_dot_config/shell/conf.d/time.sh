## use the external GNU time command, not the shell's `time` keyword ##
case "${CURRENT_SHELL}" in
  zsh)  time_bin="$(whence -p time 2>/dev/null)" ;;
  bash) time_bin="$(type -P time 2>/dev/null)" ;;
esac
[[ -n "${time_bin}" ]] && alias time="command ${time_bin}"
