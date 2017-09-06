function fpaste {
  gpaste-client history --raw --zero |
  grep -v -z "$HOME/.local/share/gpaste/images/" |
  fzf --height 35% --no-hscroll --read0 --preview-window right:50%:wrap --preview 'echo -n {}'
}

function fco {
  local tags branches target
  git rev-parse HEAD &> /dev/null || return
  tags=$(git tag --sort=-v:refname | sed 's/^/ /') || return
  branches=$(git branch -a | grep -v HEAD |
             sed -E -e 's/.* //g' -e 's|remotes/([^/]+)/(.+)|\\e[3m\1\\e[0m\t\2|' -e 's/^/ /') || return
  target=$((echo -e "$branches\n$tags") |
            fzf --border --height 35% --no-hscroll --tabstop=1 -d $'\t' -n 2,3 --ansi \
                --preview-window right:70% \
                --preview 'git log --oneline --graph --color=always --date=short \
                           --pretty="format:%C(auto)%cd %h%d %s" \
                           $(sed -E -e "s/. (.+)/\1/" -e "s|\t|/|" <<< {}) -- | head -'$LINES \
                +m -d ' ' -n 2 -q "$*") || return
  git checkout $(sed -E -e "s/^(.+[ \t])(.+)/\2/" <<< "${target}")
}

function __awless_show {
  local lock_file info
  lock_file="/tmp/awless-show.lock"
  [[ -f "${lock_file}" ]] && return
  info="$(awless show --local --siblings --color=always $1 2> /dev/null)"
  if [[ -n "${info}" ]]; then
    echo "${info}"
  else
    touch "${lock_file}"
    awless sync --infra
    rm -f "${lock_file}" &> /dev/null
  fi
}
typeset -fx __awless_show

function ec2sh {
  if [[ -z "${AWS_DEFAULT_PROFILE}" ]]; then
    echo 'No AWS credentials found in the environment!'
    return
  else
    local target
    local ssh_command
    target=$(awless ls instances --local --format tsv --no-headers \
                    --sort name,uptime --filter state=running |
             cut -f 1,3,7 |
             fzf --sync --no-hscroll --tabstop=1 -d $'\t' -n 1,2 \
                 --preview-window right:60%:wrap \
                 --preview '__awless_show {1}' \
                 --prompt "${AWS_DEFAULT_PROFILE} ❯ " --ansi -q "$*" ) || return
    ssh_command=$(awless ssh --print-cli --disable-strict-host-keychecking \
                         --private $(cut -f 1 <<< "${target}"))
    command $(sed 's/-o StrictHostKeyChecking=no//' <<< "${ssh_command}")
  fi
}
