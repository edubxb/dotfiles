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
  # shellcheck disable=SC2207
  aws_role=( $(fzf --sync --min-height 10 --height 15 -n 1 -q "$*" < "${cache_file}") ) || return
  account_id="${aws_role[1]}"
  account_name="${aws_role[0]}"
  role_name="${aws_role[2]}"
  CRED_PROFILE="${account_name}" gimme-aws-creds --roles "arn:aws:iam::${account_id}:role/${role_name}" 2> /dev/null
}

# __ec2_preview - show instance details using aws CLI (replaces awless)
__ec2_preview() {
  local profile="$1"
  local instance_id="$2"
  aws ec2 describe-instances --profile "${profile}" --instance-ids "${instance_id}" --output yaml 2>/dev/null
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

  local target instance address_idx=2

  local IFS=$'\n'
  # shellcheck disable=SC2207
  target=( $(aws ec2 describe-instances --profile "${profile}" --output=text \
                 --query "Reservations[].Instances[][InstanceId,PrivateIpAddress,PublicIpAddress,State.Name,LaunchTime]" \
                 --filters Name=instance-state-name,Values=running 2>/dev/null |
             fzf --sync --no-hscroll --tabstop=1 -d $'\t' --multi \
                 --with-nth 1..4 --nth 1,2 \
                 --expect=enter --expect=space --expect=ctrl-space \
                 --bind 'ctrl-t:toggle-all' \
                 --preview-window right:60%:wrap \
                 --preview "__ec2_preview ${profile} {1}" \
                 --prompt " ${profile} ❯ " --ansi -q "$*" | cut -f 1,3,4) )

  if [[ -n "${target}" ]]; then
    local key_bind="${target[0]}"
    local instances=( "${target[@]:1}" )

    if [[ ${key_bind} = 'enter' ]]; then
      # SSM Session Manager
      for instance in "${instances[@]:1}"; do
        kitty @ launch --type tab --tab-title "ssm-$(cut -f 1 <<< "${instance}")" \
          aws --profile "${profile}" ssm start-session --target "$(cut -f 1 <<< "${instance}")" &> /dev/null
      done
      aws --profile "${profile}" ssm start-session --target "$(cut -f 1 <<< "${instances[0]}")"
    else
      # SSH
      [[ ${key_bind} = 'ctrl-space' ]] && address_idx=3
      for instance in "${instances[@]:1}"; do
        kitty @ launch --type tab --tab-title "ssh-$(cut -f ${address_idx} <<< "${instance}")" \
          ssh "$(cut -f ${address_idx} <<< "${instance}")" &> /dev/null
      done
      ssh "$(cut -f ${address_idx} <<< "${instances[0]}")"
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
    local -a profiles
    profiles=(${(f)"$(__awskeys_list 2>/dev/null | grep "    ")"})
    _describe 'profiles' profiles
  }
  compdef _ec2sh ec2sh
fi
