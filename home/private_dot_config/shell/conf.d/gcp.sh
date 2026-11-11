## GCP completion ##
if command -v gcloud &> /dev/null; then
  if [[ ${CURRENT_SHELL} == zsh && -f /usr/share/google-cloud-sdk/completion.zsh.inc ]]; then
    source /usr/share/google-cloud-sdk/completion.zsh.inc
  else
    source <(gcloud completion "${CURRENT_SHELL}")
  fi
fi

# Guard: only load GCP functions if gcloud and fzf exist
if ! command -v gcloud &> /dev/null || ! command -v fzf &> /dev/null; then
  return 0
fi

function gcesh {
  local configuration

  if [[ -n "$1" ]]; then
    configuration="$1"
  elif [[ -n "${GCLOUD_CONFIGURATION}" ]]; then
    configuration="${GCLOUD_CONFIGURATION}"
  else
    configuration="$(gcloud config configurations list | grep True | cut -d' ' -f1)"
  fi

  shift $#

  local instance name zone ignored target session key_bind selected_instances first_instance remaining_instances

  target=$(gcloud compute instances list --configuration "${configuration}" \
                     --filter="status:running" \
                     --format="table[no-heading](name:sort=1, zone:label=zone, networkInterfaces[0].networkIP, networkInterfaces[0].accessConfigs[0].natIP)" |
              fzf --sync --no-hscroll -d ' +' --multi \
                  --with-nth 1..4 --nth 1 \
                  --expect=enter \
                  --bind 'ctrl-t:toggle-all' \
                  --preview-window right:50%:wrap \
                  --preview "gcloud compute instances describe --configuration ${configuration} --zone {2} --format='yaml(id,tags,machineType,labels,networkInterfaces,lastStartTimestamp,creationTimestamp)' {1} | bat -f -p -l yaml" \
                  --prompt " ${configuration} > " --ansi -q "$*") || return

  if [[ -n "${target}" && "${target}" == *$'\n'* ]]; then
    key_bind=${target%%$'\n'*}
    selected_instances=${target#*$'\n'}
    [[ -n "${selected_instances}" ]] || return
    first_instance=${selected_instances%%$'\n'*}
    if [[ "${selected_instances}" == *$'\n'* ]]; then
      remaining_instances=${selected_instances#*$'\n'}
    fi
    if [[ ${key_bind} = 'enter' ]]; then
      read -r name zone ignored <<< "$(tr -s ' ' <<< "${first_instance}")"
      session="gcloud_ssh#$(((RANDOM % 99) + 1))"
      kitty @ launch --type tab --tab-title "${session}" gcloud compute ssh --configuration "${configuration}" --zone "${zone}" --tunnel-through-iap "${name}" &> /dev/null
      kitty @ goto-layout --match "title:${session}" grid
      while IFS= read -r instance; do
        [[ -n "${instance}" ]] || continue
        read -r name zone ignored <<< "$(tr -s ' ' <<< "${instance}")"
        kitty @ launch --match "title:${session}" gcloud compute ssh --configuration "${configuration}" --zone "${zone}" --tunnel-through-iap "${name}" &> /dev/null
      done <<< "${remaining_instances}"
    fi
  fi
}
