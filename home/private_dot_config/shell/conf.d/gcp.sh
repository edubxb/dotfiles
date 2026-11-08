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

  local instance instances name target zone session

  _IFS="${IFS}"
  IFS=$'\n'
  target=( $(gcloud compute instances list --configuration "${configuration}" \
                     --filter="status:running" \
                     --format="table[no-heading](name:sort=1, zone:label=zone, networkInterfaces[0].networkIP, networkInterfaces[0].accessConfigs[0].natIP)" |
              fzf --sync --no-hscroll -d ' +' --multi \
                  --with-nth 1..4 --nth 1 \
                  --expect=enter \
                  --bind 'ctrl-t:toggle-all' \
                  --preview-window right:50%:wrap \
                  --preview "gcloud compute instances describe --configuration ${configuration} --zone {2} --format='yaml(id,tags,machineType,labels,networkInterfaces,lastStartTimestamp,creationTimestamp)' {1} | bat -f -p -l yaml" \
                  --prompt " ${configuration} > " --ansi -q "$*") )
  IFS="${_IFS}"

  if [[ -n "${target}" ]]; then
    key_bind="${target[@]:0:1}"
    instances=( "${target[@]:1}" )
    if [[ ${key_bind} = 'enter' ]]; then
      name=$((tr -s " " | cut -d " " -f 1) <<< ${instances[1]})
      zone=$((tr -s " " | cut -d " " -f 2) <<< ${instances[1]})
      session="gcloud_ssh#$(((RANDOM % 99) + 1))"
      kitty @ launch --type tab --tab-title "${session}" gcloud compute ssh --configuration "${configuration}" --zone "${zone}" --tunnel-through-iap "${name}" &> /dev/null
      kitty @ goto-layout --match "title:${session}" grid
      for instance in "${instances[@]:1}"; do
        name=$((tr -s " " | cut -d " " -f 1) <<< ${instance})
        zone=$((tr -s " " | cut -d " " -f 2) <<< ${instance})
        kitty @ launch --match "title:${session}" gcloud compute ssh --configuration "${configuration}" --zone "${zone}" --tunnel-through-iap "${name}" &> /dev/null
      done
    fi
  fi
}