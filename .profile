if [ -d "${HOME}/.local/bin" ]; then
  PATH="${HOME}/.local/bin:${PATH}"
fi

## ruby gems config ##
export GEM_HOME="${HOME}/.local/lib/gem/ruby/2.3.0/"
export GEM_PATH="${GEM_HOME}"
export PATH="$PATH:${GEM_PATH}/bin"

## npm config ##
export NPM_PACKAGES="${HOME}/.local/lib/node_modules"
export NODE_PATH="${HOME}/.npm:${NODE_PATH}"
export MANPATH="$(manpath):$NPM_PACKAGES/share/man"
export PATH="$PATH:${NPM_PACKAGES}/bin"
