function fpaste {
  gpaste-client history --zero |
  grep -v -z "\[Image, .*\]" |
  fzf --border --height 14 --no-hscroll --read0 -d ' ' -n 2.. \
      --preview-window right:50%:wrap --preview 'echo {2..}' \
      --bind 'ctrl-x:execute-silent(gpaste-client delete {1})' |
  cut -d ' ' -f 2-
}

function fco {
  local tags local_branches remote_branches target
  git rev-parse HEAD &> /dev/null || return
  tags=$(git tag --sort=-v:refname | sed 's/^/ /') || return
  remote_branches=$(git branch -r | sed -nE '/HEAD/!s|.* ([^/]+)/(.+)| \\e[3m\1\\e[0m \2|p') || return
  local_branches=$(git branch | sed -E 's/.* (.+)/ \1/') || return
  [[ -n "${remote_branches}" ]] && remote_branches="\n${remote_branches}"
  [[ -n "${tags}" ]] && tags="\n${tags}"
  target=$((echo -e "${local_branches}${remote_branches}${tags}") |
            fzf --border --height 35% --no-hscroll --tabstop=1 -d ' ' -n 2.. --ansi \
                --preview-window right:70% \
                --preview 'git log --oneline --graph --color=always --date=short \
                               --pretty="format:%C(auto)%cd %h%d %s" \
                           $(tr " " "/" <<< {2..}) -- | head -'$LINES \
                +m -q "$*" | sed -E "s/(.+ )?(.+)/\2/") || return
  git checkout "${target}"
}

function fak {
    local target
    target=$(__awskeys_list | grep "^ " | tr -d ' ' |
             fzf --min-height 10 --height 15 -q "$*") || return
    __awskeys_export "${target}"
}

function __awless_show {
  local lock_file
  lock_file="/tmp/awless-show.lock"
  [[ -f "${lock_file}" ]] && return
  awless show --silent --local --siblings --color=always $1 2> /dev/null
  if [[ "$?" -ne 0 ]]; then
    touch "${lock_file}" &> /dev/null
    awless sync --silent --infra 2> /dev/null
    rm -f "${lock_file}" &> /dev/null
    awless show --silent --local --siblings --color=always $1 2> /dev/null
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
    target=$(awless ls instances --silent --format tsv --no-headers \
                    --sort name,uptime --filter state=running |
             cut -f 1,3,7 |
             fzf --sync --no-hscroll --tabstop=1 -d $'\t' -n 1,2 \
                 --preview-window right:60%:wrap \
                 --preview '__awless_show {1}' \
                 --prompt " ${AWS_DEFAULT_PROFILE} ❯ " --ansi -q "$*" ) || return
    ssh_command=$(awless ssh --print-cli --disable-strict-host-keychecking \
                         --private $(cut -f 1 <<< "${target}"))
    command $(sed 's/-o StrictHostKeyChecking=no//' <<< "${ssh_command}")
  fi
}
