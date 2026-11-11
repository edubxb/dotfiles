## AWS ##
export AWS_DEFAULT_OUTPUT="text"
export AWS_CONFIG_FILE="${CONFIG_PATH}/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="${CONFIG_PATH}/aws/credentials"

# AWS CLI completion (bash only; zsh handles via compinit)
if [[ -n "${BASH_VERSION:-}" ]] && command -v complete &> /dev/null && \
  command -v aws &> /dev/null && \
  command -v aws_completer &> /dev/null; then
  complete -C "$(command -v aws_completer)" aws
fi

# Guard: only load AWS functions if aws CLI and fzf exist
if ! command -v aws &> /dev/null || ! command -v fzf &> /dev/null; then
  return 0
fi

# fap - pick AWS profile from config
fap() {
  local target
  target=$(grep profile "${AWS_CONFIG_FILE}" 2>/dev/null |
           sed -nr -e 's/\[profile (.+)\]/\1/p' |
           fzf --min-height 10 --height 15 -q "$*" ) || return
  export AWS_PROFILE="${target}"
}

# fak - pick AWS keys (requires __awskeys_list/__awskeys_export from env)
fak() {
  local target
  target=$(__awskeys_list 2>/dev/null | grep "^ " | tr -d ' ' |
           fzf --min-height 10 --height 15 -q "$*") || return
  __awskeys_export "${target}"
}

# fok - assume role via gimme-aws-creds
fok() {
  local aws_role account_id account_name role_name
  local cache_max_age=1440
  local cache_file="${HOME}/.cache/bash_fok"
  if [[ ! -f "${cache_file}" ]] || [[ "$(find "${cache_file}" -mmin +${cache_max_age} 2> /dev/null)" ]]; then
    gimme-aws-creds --action-list-roles 2> /dev/null | \
    sed -nE "s/.+'Account: ([^ ]+) \(([0-9]+)\)', friendly_role_name='(.+)'\)/\1 \2 \3/p" | \
    column -t > "${cache_file}"
  fi
  aws_role=$(fzf --sync --min-height 10 --height 15 -n 1 -q "$*" < "${cache_file}") || return
  read -r account_name account_id role_name <<< "${aws_role}"
  CRED_PROFILE="${account_name}" gimme-aws-creds --roles "arn:aws:iam::${account_id}:role/${role_name}" 2> /dev/null
}

# jq filter shared by ec2md() and the ec2sh preview
EC2MD_FILTER='.Reservations[0].Instances[0] as $i | ["| Field | Value |", "| --- | --- |", "| ID | `\($i.InstanceId)` |", "| Type | \($i.InstanceType) |", "| State | \($i.State.Name) |", "| AZ | \($i.Placement.AvailabilityZone) |", "| Private IP | \($i.PrivateIpAddress // "-") |", "| Public IP | \($i.PublicIpAddress // "-") |", "| Launch | \($i.LaunchTime) |", "| Image | \($i.ImageId) |", "", "## Tags", "", "| Key | Value |", "| --- | --- |"] + (($i.Tags // []) | sort_by(.Key) | map("| \(.Key) | \(.Value) |")) + [""] | join("\n")'

# ec2md - render an instance's details as markdown
ec2md() {
  aws ec2 describe-instances --profile "${1}" --instance-ids "${2}" --output json 2>/dev/null \
    | jq -r "${EC2MD_FILTER}" \
    | gum format
}

# ec2sh - pick running EC2 instances and connect via SSM or SSH
ec2sh() {
  local profile

  if [[ -n "$1" ]]; then
    profile="$1"
  elif [[ -n "${AWS_PROFILE}" ]]; then
    profile="${AWS_PROFILE}"
  else
    echo 'No AWS credentials found in the environment!'
    return 1
  fi

  shift

  local target key_bind selected_instances first_instance remaining_instances instance address_idx=2

  target=$(aws ec2 describe-instances --profile "${profile}" --output=text \
                 --query "Reservations[].Instances[][InstanceId,PrivateIpAddress,PublicIpAddress,not_null(Tags[?Key=='Name']|[0].Value,'-')]" \
                 --filters Name=instance-state-name,Values=running 2>/dev/null |
             fzf --sync --no-hscroll --tabstop=8 -d $'\t' --multi \
                 --nth 1,2,4 \
                 --expect=space --expect=ctrl-space \
                 --bind 'ctrl-t:toggle-all' \
                 --preview-window right:60%:wrap \
                 --preview "aws ec2 describe-instances --profile ${profile} --instance-ids {1} --output json 2>/dev/null | jq -r '${EC2MD_FILTER}' | gum format" \
                 --prompt " ${profile} ❯ " --ansi -q "$*" | cut -f 1,2,3) || return

  if [[ -n "${target}" && "${target}" == *$'\n'* ]]; then
    key_bind=${target%%$'\n'*}
    selected_instances=${target#*$'\n'}
    [[ -n "${selected_instances}" ]] || return
    first_instance=${selected_instances%%$'\n'*}
    if [[ "${selected_instances}" == *$'\n'* ]]; then
      remaining_instances=${selected_instances#*$'\n'}
    fi

    if [[ -z "${key_bind}" ]]; then
      # SSM Session Manager
      while IFS= read -r instance; do
        [[ -n "${instance}" ]] || continue
        kitty @ launch --type tab --tab-title "ssm-$(cut -f 1 <<< "${instance}")" \
          aws --profile "${profile}" ssm start-session --target "$(cut -f 1 <<< "${instance}")" &> /dev/null
      done <<< "${remaining_instances}"
      aws --profile "${profile}" ssm start-session --target "$(cut -f 1 <<< "${first_instance}")"
    else
      # SSH
      [[ ${key_bind} = 'ctrl-space' ]] && address_idx=3
      while IFS= read -r instance; do
        [[ -n "${instance}" ]] || continue
        kitty @ launch --type tab --tab-title "ssh-$(cut -f ${address_idx} <<< "${instance}")" \
          ssh "$(cut -f ${address_idx} <<< "${instance}")" &> /dev/null
      done <<< "${remaining_instances}"
      ssh "$(cut -f ${address_idx} <<< "${first_instance}")"
    fi
  fi
}

# Completion for ec2sh (bash)
if [[ -n "${BASH_VERSION:-}" ]]; then
  __ec2sh_comp() {
    local cur
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    [[ "${COMP_CWORD}" -eq 2 ]] && return 0
    local profile_list
    profile_list="$(__awskeys_list 2>/dev/null | grep "    ")"
    COMPREPLY=( $(compgen -W "${profile_list}" -- "${cur}") )
    return 0
  }
  complete -F __ec2sh_comp ec2sh
# zsh completion
elif [[ -n "${ZSH_VERSION:-}" ]]; then
  _ec2sh() {
    local profile
    while IFS= read -r profile; do
      compadd -- "${profile#    }"
    done < <(__awskeys_list 2>/dev/null | grep '^    ')
  }
  compdef _ec2sh ec2sh
fi
