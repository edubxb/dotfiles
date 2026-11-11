## Environment functions ##
# Guard: only load if fzf and wl-copy (wayland clipboard) exist
if ! command -v fzf &> /dev/null || ! command -v wl-copy &> /dev/null; then
  return 0
fi

function fev {
  target=$(env | cut -d'=' -f 1 | sort | \
           fzf --height 11 +s --no-border \
               --preview-window right:60%:wrap \
               --preview 'printenv {}' \
               --bind 'ctrl-x:execute-silent(unset {1})')

  [[ -n "${target}" ]] && wl-copy "$(printenv "${target}")"
}
