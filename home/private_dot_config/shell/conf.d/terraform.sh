## Terraform functions ##
# Guard: only load if terraform, fzf, jq, and batcat exist
if ! command -v terraform &> /dev/null || ! command -v fzf &> /dev/null || ! command -v jq &> /dev/null || ! command -v batcat &> /dev/null; then
  return 0
fi

function tfsb {
  local resources state_file

  state_file="$(mktemp /tmp/tfstate.XXXXX)"
  terraform state pull > "${state_file}" || return
  resources=$(jq -r '.resources[] | [.module // empty, .type, .name] | join(".") | sort' < "${state_file}") || return

  fzf --sync --no-hscroll -d ' +' \
      --preview-window down:70%:wrap \
      --preview "jq -r {1} < ${state_file} | batcat -f -p -l json" \
      --ansi -q "$*" <<< ${resources}

  rm -f "${state_file}"
}