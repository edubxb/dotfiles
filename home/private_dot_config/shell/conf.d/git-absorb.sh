## git absorb ##
if [[ ${CURRENT_SHELL} == zsh ]]; then
  if [[ -x /usr/lib/git-core/git-absorb ]]; then
    zstyle -g existing_user_commands ':completion:*:*:git:*' user-commands
    zstyle ':completion:*:*:git:*' user-commands $existing_user_commands \
        absorb:'automatically absorb staged changes into your current branch'
    git absorb --gen-completions zsh > "${HOME}/.zfunc/_git-absorb"
  fi
else
  if command -v git-absorb &> /dev/null; then
    eval "$(git absorb --gen-completions bash)"
  fi
fi
