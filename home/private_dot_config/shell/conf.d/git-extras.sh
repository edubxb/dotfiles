## git-extras ##
if [[ ${CURRENT_SHELL} == zsh ]]; then
  if [[ -f /usr/share/zsh/vendor-completions/_git-extras ]]; then
    source /usr/share/zsh/vendor-completions/_git-extras
  fi
else
  if [[ -f /usr/share/bash-completion/completions/git-extras ]]; then
    source /usr/share/bash-completion/completions/git-extras
  fi
fi
