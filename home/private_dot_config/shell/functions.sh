function fp {
  local directory_list="$(tr ':' '\n' <<< ${PROJECTS_PATH})"
  local projects=$(
    for ppath in ${=directory_list}; do
      echo ${ppath}/* | sed "s|$HOME/||g" | tr ' ' '\n' | sed -E 's|([^ ]+)/([^/]+)|\\e[3m\1\\e[0m \2|'
    done
  )
  target=( $(echo -en "${projects}" |
             fzf --height 50% --no-hscroll -n 2 --ansi -1 -q "$*" \
             --preview 'glow --style dark $(fdfind README.{md,rst,txt} ${HOME}/{1}/{2} 2> /dev/null | tail -n1)') ) || return
  cd "${HOME}/${target[1]}/${target[2]}"
}

function fev {
  target=$(env | cut -d'=' -f 1 | sort | \
           fzf --height 11 +s --no-border \
               --preview-window right:60%:wrap \
               --preview 'printenv {}' \
               --bind 'ctrl-x:execute-silent(unset {1})')
  wl-copy "$(printenv ${target})"
}

function fsb {
  local tags local_branches remote_branches target
  git rev-parse HEAD &> /dev/null || return
  tags=$(git tag --sort=-v:refname | sed 's/^/ /')
  remote_branches=$(git branch -r | sed -nE '/HEAD/!s|.* ([^/]+)/(.+)| \\e[3m\1\\e[0m \2|p')
  local_branches=$(git branch | sed -E 's/.* (.+)/ \1/') || return
  [[ -n "${remote_branches}" ]] && remote_branches="\n${remote_branches}"
  [[ -n "${tags}" ]] && tags="\n${tags}"
  target=$(echo -e "${local_branches}${remote_branches}${tags}" |
           fzf --border --height 35% --no-hscroll --tabstop=1 -d ' ' -n 2.. --ansi \
               --preview-window right:70% \
               --preview 'git log --oneline --graph --color=always --date=short \
                              --pretty="format:%C(auto)%cd %h%d %C(blue)%an %Creset%s" \
                          $(tr " " "/" <<< {2..}) -- | head -'$LINES \
               +m -q "$*") || return

   git checkout $(sed -E "s/(.+ )?(.+)/\2/" <<< "${target}")
}

function fas {
  local files

  git rev-parse HEAD &> /dev/null || return
  files=$(git -c color.status=always status --short)
  [[ -n "${files}" ]] || return
  target=$(fzf --border --height 100% --no-hscroll -n 2.. -m --ansi \
               --preview-window bottom:75% \
               --preview 'FILE=$(cut -d" " -f 2 <<< {2..}); git diff --color=always --exit-code "${FILE}" && git diff --color=always --staged "${FILE}"' \
               --bind 'ctrl-o:execute-silent(xdg-open $(cut -d" " -f 1 <<< {2..}))' \
               --bind 'ctrl-t:execute-silent(git difftool $(cut -d" " -f 1 <<< {2..}))' \
               <<< "${files}" | sed -E 's/^ ?. (.+)/\1/') || return

  [[ -n "${target}" ]] && git add ${target}
}

function fap {
  local target
  target=$(grep profile ${AWS_CONFIG_FILE} |
           sed -nr -e 's/\[profile (.+)\]/\1/p' |
           fzf --min-height 10 --height 15 -q "$*" ) || return
  export AWS_PROFILE="${target}"
}

function fak {
  local target
  target=$(__awskeys_list | grep "^ " | tr -d ' ' |
           fzf --min-height 10 --height 15 -q "$*") || return
  __awskeys_export "${target}"
}

function fok {
  local aws_role
  local account_id
  local account_name
  local role_name
  local cache_max_age=1440
  local cache_file="${HOME}/.cache/bash_fok"
  if [[ ! -f "${cache_file}" ]] || [[ "$(find "${cache_file}" -mmin +${cache_max_age} 2> /dev/null)" ]]; then
    gimme-aws-creds --action-list-roles 2> /dev/null | \
    sed -nE "s/.+'Account: ([^ ]+) \(([0-9]+)\)', friendly_role_name='(.+)'\)/\1 \2 \3/p" | \
    column -t > "${cache_file}"
  fi
  aws_role=( $(fzf --sync --min-height 10 --height 15 -n 1 -q "$*" < "${cache_file}") ) || return
  account_id="${aws_role[1]}"
  account_name="${aws_role[0]}"
  role_name="${aws_role[2]}"
  CRED_PROFILE="${account_name}" gimme-aws-creds --roles "arn:aws:iam::${account_id}:role/${role_name}" 2> /dev/null
}

function __awless_show {
  local lock_file
  lock_file="/tmp/awless-show.lock"
  [[ -f "${lock_file}" ]] && return
  awless show -p $1 --silent --local --siblings --color=always $2 2> /dev/null
  if [[ "$?" -ne 0 ]]; then
    touch "${lock_file}" &> /dev/null
    awless sync -p $1 --silent --infra 2> /dev/null
    rm -f "${lock_file}" &> /dev/null
    awless sync -p $1 --silent --local --siblings --color=always $2 2> /dev/null
  fi
}
function ec2sh {
  local profile

  if [[ -n "$1" ]]; then
    profile="$1"
  elif [[ -n "${AWS_PROFILE}" ]]; then
    profile="${AWS_PROFILE}"
  else
    echo 'No AWS credentials found in the environment!'
    return
  fi

  shift

  local target
  local host
  local instance
  local msg
  local address_idx=2

  _IFS="${IFS}"
  IFS=$'\n'
  target=( $(aws ec2 describe-instances --profile ${profile} --output=text \
                 --query "Reservations[].Instances[][InstanceId,PrivateIpAddress,PublicIpAddress,State.Name,LaunchTime]" \
                 --filters Name=instance-state-name,Values=running  |
             fzf --sync --no-hscroll --tabstop=1 -d $'\t' --multi \
                 --with-nth 1..4 --nth 1,2 \
                 --expect=enter --expect=space --expect=ctrl-space\
                 --bind 'ctrl-t:toggle-all' \
                 --preview-window right:60%:wrap \
                 --preview "__awless_show ${profile} {1}" \
                 --prompt " ${profile} ❯ " --ansi -q "$*" | cut -f 1,3,4) )
  IFS="${_IFS}"

  if [[ -n "${target}" ]]; then
    key_bind="${target[0]}"
    instances=( "${target[@]:1}" )
    if [[ ${key_bind} = 'enter' ]]; then
      for instance in "${instances[@]:1}"; do
        tilix -a session-add-down \
              -e "aws --profile ${profile} ssm start-session --target $(cut -f 1 <<< ${instance})"
      done
      aws --profile "${profile}" ssm start-session --target $(cut -f 1 <<< ${instances[0]})
    else
      [[ ${key_bind} = 'ctrl-space' ]] && address_idx=3
      for instance in "${instances[@]:1}"; do
          tilix -a session-add-down -e "ssh $(cut -f ${address_idx} <<< ${instance})"
       done
      ssh $(cut -f ${address_idx} <<< ${instances[0]})
    fi
  fi
}

function __ec2sh_comp {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  [[ "${COMP_CWORD}" -eq 2 ]] && return 0

  local profile_list="$(__awskeys_list | grep "    ")"
  COMPREPLY=( $(compgen -W "${profile_list}" -- ${cur}) )

  return 0
}
complete -F __ec2sh_comp ec2sh


function gcesh {
  local configuration

  if [[ -n "$1" ]]; then
    configuration="$1"
  elif [[ -n "${GCLOUD_CONFIGURATION}" ]]; then
    configuration="${GCLOUD_CONFIGURATION}"
  else
    configuration="$(gcloud config configurations list | grep True | cut -d' ' -f1)"
  fi

  shift

  local target
  local host
  local instance
  local msg
  local address_idx=2

  _IFS="${IFS}"
  IFS=$'\n'
  target=( $(gcloud compute instances list --configuration ${configuration} \
                    --filter="status:running" \
                    --format="table[no-heading](name:sort=1, zone:label=zone, networkInterfaces[0].networkIP, networkInterfaces[0].accessConfigs[0].natIP)" |
                fzf --sync --no-hscroll -d ' +' --multi \
                    --with-nth 1..4 --nth 1,2 \
                    --expect=enter \
                    --bind 'ctrl-t:toggle-all' \
                    --preview-window right:60%:wrap \
                    --preview "__gce_show ${configuration} {2} {1}" \
                    --prompt " ${configuration} ❯ " --ansi -q "$*" |
                 tr -s " " | tr " " "\t" | cut -f 1,2) )
  IFS="${_IFS}"

  if [[ -n "${target}" ]]; then
    key_bind="${target[0]}"
    instances=( "${target[@]:1}" )
    if [[ ${key_bind} = 'enter' ]]; then
      for instance in "${instances[@]:1}"; do
        kitty @ launch gcloud compute ssh --configuration ${configuration} --zone $(cut -f 2 <<< ${instance}) --tunnel-through-iap $(cut -f 1 <<< ${instance}) &> /dev/null
      done
      gcloud compute ssh --configuration ${configuration} --zone $(cut -f 2 <<< ${instances[0]}) --tunnel-through-iap $(cut -f 1 <<< ${instances[0]}) 2> /dev/null
    fi
  fi
}

function tfsb {
  local resources
  resources=$(terraform state list) || return

  terraform state list | \
  fzf --sync --no-hscroll -d ' +' \
      --preview-window down:70%:wrap \
      --preview "terraform state show -no-color {1} | batcat -f -p -l hcl" \
      --ansi -q "$*"
}
