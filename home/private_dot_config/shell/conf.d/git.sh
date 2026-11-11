## Git functions ##
# Guard: only load if git and fzf exist
if ! command -v git &> /dev/null || ! command -v fzf &> /dev/null; then
  return 0
fi

function fsb {
  local tags local_branches remote_branches choices target
  git rev-parse HEAD &> /dev/null || return
  tags=$(git tag --sort=-v:refname | sed 's/^/ /')
  remote_branches=$(git branch -r | sed -nE '/HEAD/!s|.* ([^/]+)/(.+)| \e[3m\1\e[0m \2|p')
  local_branches=$(git branch | sed -E 's/.* (.+)/ \1/') || return
  choices=${local_branches}
  [[ -n "${remote_branches}" ]] && choices+=$'\n'"${remote_branches}"
  [[ -n "${tags}" ]] && choices+=$'\n'"${tags}"
  target=$(printf '%s\n' "${choices}" |
           fzf --border --height 35% --no-hscroll --tabstop=1 -d ' ' -n 2.. --ansi \
               --preview-window right:70% \
               --preview 'git log --oneline --graph --color=always --date=short \
                          --pretty="format:%C(auto)%cd %h%d %C(blue)%an %Creset%s" \
                      $(tr " " "/" <<< {2..}) -- | head -'$LINES \
               +m -q "$*") || return

  [[ -n "${target}" ]] && git checkout "$(sed -E "s/(.+ )?(.+)/\2/" <<< "${target}")"
}

function fas {
  local files target file

  git rev-parse HEAD &> /dev/null || return
  files=$(git -c color.status=always status --short)
  [[ -n "${files}" ]] || return
  target=$(fzf --border --height 100% --no-hscroll -n 2.. -m --ansi \
               --preview-window bottom:75% \
               --preview 'FILE=$(cut -d" " -f 2 <<< {2..}); git diff --color=always --exit-code "${FILE}" && git diff --color=always --staged "${FILE}"' \
               --bind 'ctrl-o:execute-silent(xdg-open $(cut -d" " -f 1 <<< {2..}))' \
               --bind 'ctrl-t:execute-silent(git difftool $(cut -d" " -f 1 <<< {2..}))' \
               <<< "${files}" | sed -E 's/^ ?. (.+)/\1/') || return

  [[ -n "${target}" ]] || return
  while IFS= read -r file; do
    [[ -n "${file}" ]] && git add -- "${file}" || return
  done <<< "${target}"
}
