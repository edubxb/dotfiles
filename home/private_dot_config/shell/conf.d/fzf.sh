## fzf ##
if command -v fzf &> /dev/null; then
  if [[ ${CURRENT_SHELL} == zsh ]] && [[ -n "${ZINIT_HOME:-}" ]]; then
    zinit for light-mode Aloxaf/fzf-tab
  fi

  source <(fzf "--${CURRENT_SHELL}")

  if [[ ${CURRENT_SHELL} == zsh ]] && [[ -n "${ZINIT_HOME:-}" ]]; then
    zinit for https://github.com/junegunn/fzf-git.sh/blob/main/fzf-git.sh
  fi

  if [[ ${CURRENT_SHELL} == zsh ]]; then
    fzf-history-widget() {
      local selected selected_command index_width
      index_width=${#HISTSIZE}
      (( index_width < 1 )) && index_width=4
      selected=$(fc -rli 1 |
        sed -E 's/^[[:space:]]*([0-9]+)\*?[[:space:]]+([^[:space:]]+[[:space:]]+[^[:space:]]+)[[:space:]]+(.*)$/\1\t\2\t\3/' |
        while IFS=$'\t' read -r index timestamp command; do
          printf '%-*s\t%-19s\t%s\n' "${index_width}" "${index}" "${timestamp}" "${command}"
        done |
        fzf --height 50% --layout=reverse --delimiter=$'\t' \
            --with-nth=1,2,3 --nth=3.. --query="${LBUFFER}" ${=FZF_CTRL_R_OPTS})

      if [[ -n "${selected}" ]]; then
        selected_command="${selected#*$'\t'}"
        LBUFFER="${selected_command#*$'\t'}"
        CURSOR=${#LBUFFER}
      fi
      zle reset-prompt
    }
    zle -N fzf-history-widget
  fi

  export FZF_DEFAULT_OPTS="--filepath-word --no-mouse --reverse \
                           --inline-info --tabstop=4 \
                           --pointer='‣' --marker='•' \
                           --color hl:#DBC074,hl+:#C94F6D,fg:#DFDFE5,fg+:#DFDFE5,bg+:#223249 \
                           --color prompt:#719CD6,spinner:#719CD6,pointer:#CDCECF,marker:#DFDFE5 \
                           --color header:#DFDFE5,info:#81B29A,border:#719CD6"

  if [[ ${CURRENT_SHELL} == bash ]]; then
    export FZF_DEFAULT_COMMAND="fdfind --type f --hidden --follow --exclude .git --strip-cwd-prefix"
    export FZF_ALT_C_COMMAND="fdfind --type d --hidden --follow --exclude .git --strip-cwd-prefix"
    export FZF_CTRL_T_COMMAND="fdfind --type f --type d --hidden --follow --exclude .git --strip-cwd-prefix"
    export FZF_ALT_C_OPTS="--preview 'eza --icons=auto --color=always --tree --color-scale --group-directories-first {}'"
  else
    export FZF_DEFAULT_COMMAND="fdfind --type f --hidden --follow --strip-cwd-prefix"
    export FZF_ALT_C_COMMAND="fdfind --type d --hidden --follow --strip-cwd-prefix"
    export FZF_CTRL_T_COMMAND="fdfind --type f --type d --hidden --follow --strip-cwd-prefix"
    export FZF_ALT_C_OPTS="--preview 'eza --icons=auto --color=always --tree --color-scale --group-directories-first {}'"
  fi

  export FZF_CTRL_T_OPTS="--preview 'batcat -n --color=always {}'"
fi
