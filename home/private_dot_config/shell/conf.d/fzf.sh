## fzf ##
if command -v fzf &> /dev/null; then
  # Atuin owns Ctrl-R (see atuin.sh); stop fzf's shell integration from binding it
  export FZF_CTRL_R_COMMAND=""
  export FZF_DEFAULT_OPTS="--filepath-word --no-mouse --reverse \
                           --inline-info --tabstop=4 \
                           --pointer='‣' --marker='•' \
                           --color hl:#DBC074,hl+:#C94F6D,fg:#DFDFE5,fg+:#DFDFE5,bg+:#223249 \
                           --color prompt:#719CD6,spinner:#719CD6,pointer:#CDCECF,marker:#DFDFE5 \
                           --color header:#DFDFE5,info:#81B29A,border:#719CD6"

  export FZF_DEFAULT_COMMAND="fdfind --type f --hidden --follow --exclude .git --strip-cwd-prefix"
  export FZF_ALT_C_COMMAND="fdfind --type d --hidden --follow --exclude .git --strip-cwd-prefix"
  export FZF_CTRL_T_COMMAND="fdfind --type f --type d --hidden --follow --exclude .git --strip-cwd-prefix"
  export FZF_ALT_C_OPTS="--preview 'eza --icons=auto --color=always --tree --color-scale --group-directories-first {}'"
  export FZF_CTRL_T_OPTS="--preview 'batcat -n --color=always {}'"

  source <(fzf "--${CURRENT_SHELL}")

  if [[ ${CURRENT_SHELL} == zsh ]] && [[ -n "${ZINIT_HOME:-}" ]]; then
    zinit for light-mode Aloxaf/fzf-tab
  fi

  if [[ ${CURRENT_SHELL} == zsh ]] && [[ -n "${ZINIT_HOME:-}" ]]; then
    zinit for https://github.com/junegunn/fzf-git.sh/blob/main/fzf-git.sh
  fi
fi
