function fpaste {
  gpaste-client history --raw --zero |
  grep -v -z "$HOME/.local/share/gpaste/images/" |
  fzf --height 35% --no-hscroll --read0 --preview-window right:50%:wrap --preview 'echo -n {}'
}

function fco {
  local tags branches target
  git rev-parse HEAD &> /dev/null || return
  tags=$(git tag | sort -Vr | sed 's/^/ /') || return
  branches=$(git branch | sort -fu | sed -e 's/.* //' -e 's/^/ /') || return
  target=$((echo "$branches" "$tags") | sed '/^$/d' |
            fzf --border --height 35% --no-hscroll --ansi \
                --preview-window right:70% \
                --preview 'git log --oneline --graph --color=always --date=short \
                           --pretty="format:%C(auto)%cd %h%d %s" \
                           $(sed -r -e "s/.+( +|\t)(.+)/\2/" <<< {}) -- | head -'$LINES \
                +m -d ' ' -n 2 -q "$*") || return
  git checkout $(echo "$target" | cut -d ' ' -f2)
}

function __awless_show {
  local lock_file info
  lock_file="/tmp/awless-show.lock"
  [[ -f "${lock_file}" ]] && return
  info="$(awless show --local --siblings $1 2> /dev/null)"
  if [[ -n "${info}" ]]; then
    echo -ne "${info}"
  else
    touch "${lock_file}"
    awless sync --infra
    rm -f "${lock_file}" &> /dev/null
  fi
}
typeset -fx __awless_show

function ec2sh {
  local target
  if [[ -z "${AWS_DEFAULT_PROFILE}" ]]; then
    echo 'No AWS credentials found in the environment!'
    return
  else
    target=$(awless ls instances --format tsv --no-headers \
                    --sort name,uptime --filter state=running |
             cut -f 1,3,7 |
             fzf --sync --no-hscroll --tabstop=1 -d $'\t' -n 1,2 --ansi \
                 --preview-window right:60% \
                 --preview '__awless_show $(cut -f1 <<< {})') || return
    awless ssh --private $(cut -f 1 <<< "${target}" )
  fi
}
