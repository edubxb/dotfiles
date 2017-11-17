## Some alias to avoid making mistakes ##
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

## nuke ##
alias nuke='killall -9 '

## yank ##
alias yank='yank-cli'

## Better integration with GUI tools ##
alias open='xdg-open'

## rg default args ##
alias rg="rg -S --colors 'path:fg:white' --colors 'path:style:bold' --colors 'match:fg:yellow' --colors 'line:fg:white' --colors 'line:style:bold'"

## tig reflog ##
alias trl='git reflog --pretty=raw | tig --pretty=raw'

## neovim remote ##
alias nvim="nvr"

## typos ##
alias awsless="awless"

## python ##
alias pylint="pylint3"

## Bash-it overrides ##
alias ll="ls -lh"
