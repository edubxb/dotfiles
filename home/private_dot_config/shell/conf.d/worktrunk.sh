## worktrunk shell integration ##
if command -v wt >/dev/null 2>&1; then
  case "${CURRENT_SHELL}" in
    zsh)
      # conf.d runs before compinit; completion needs compdef, so defer
      # to the first prompt, where compinit has already run.
      _wt_shell_init() {
        eval "$(command wt config shell init zsh)"
        add-zsh-hook -d precmd _wt_shell_init
      }
      autoload -Uz add-zsh-hook
      add-zsh-hook precmd _wt_shell_init
      ;;
    bash)
      eval "$(command wt config shell init bash)"
      ;;
  esac
fi
