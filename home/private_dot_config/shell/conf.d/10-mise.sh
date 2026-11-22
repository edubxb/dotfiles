## mise ##
if command -v mise &> /dev/null; then
  eval "$(mise activate "${CURRENT_SHELL}")"

  case "${CURRENT_SHELL}" in
    zsh)  mise_comp="${HOME}/.zfunc/_mise" ;;
    bash) mise_comp="${XDG_CACHE_HOME:-${HOME}/.cache}/shell/mise-completion.bash" ;;
  esac
  if [[ ! -s "${mise_comp}" ]] || [[ -n "$(find "${mise_comp}" -mmin +10080 2> /dev/null)" ]]; then
    mkdir -p "${mise_comp%/*}"
    mise completion "${CURRENT_SHELL}" > "${mise_comp}.tmp" 2> /dev/null \
      && mv -f "${mise_comp}.tmp" "${mise_comp}" \
      || rm -f "${mise_comp}.tmp"
  fi
  [[ ${CURRENT_SHELL} == bash && -s "${mise_comp}" ]] && source "${mise_comp}"
  unset mise_comp
fi
