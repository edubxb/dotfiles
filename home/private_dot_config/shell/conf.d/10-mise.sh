## mise ##
if command -v mise &> /dev/null; then
  eval "$(mise activate "${CURRENT_SHELL}")"

  if [[ ${CURRENT_SHELL} == zsh ]]; then
    [[ -f "${HOME}/.zfunc/_mise" ]] || mise completion "${CURRENT_SHELL}" > "${HOME}/.zfunc/_mise"
  else
    eval "$(mise completion bash)"
  fi
fi
