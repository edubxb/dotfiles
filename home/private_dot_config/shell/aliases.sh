## Some alias to avoid making mistakes ##
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

## cat with wings ##
if which batcat &> /dev/null; then
  # Debian package
  alias cat='batcat -p'
else
  # Upstream package
  alias cat='bat -p'
fi

## rg ##
alias rgh='rg --hidden'

## fd ##
alias fd='fdfind'

## nuke ##
alias nuke='killall -9 '

## yank ##
alias yank='yank-cli'

## colors are wonderful ##
alias ip='ip --color'

## Better integration with GUI tools ##
alias open='xdg-open'

## lsd ##
alias ls='lsd --group-dirs first'
alias ll='lsd -l --group-dirs first'
alias lla='lsd -la --group-dirs first'
alias tree='lsd --tree'

## k8s ##
alias kube='kubectl'
alias kubenctx='kubectl config unset current-context'

## terraform ##
alias tf='terraform'

## useful ##
alias myip='curl https://api.ipify.org/'

## git ##
alias gb='git branch'
alias gc='git commit -v'
alias gcm='git commit -v -m'
alias gsb='git switch'
alias gsc='git switch -c'
alias gl='git pull'
alias gf='git fetch --all --prune'
alias gft='git fetch --all --prune --tags'
alias gs='git status'
alias gss='git status -s'
alias ghm='cd "$(git rev-parse --show-toplevel)"'

## some fun ##
alias bonsai='cbonsai -l -i'
alias fireworks='confetty fireworks'
alias matrix='neo -D --speed=12 --density=3 --lingerms=1,1 --rippct=0'
alias pipes='pipes-rs -b true -c rgb -k curved -p 25'
