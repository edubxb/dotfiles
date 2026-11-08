## Oh My Posh ##
if ! command -v git &> /dev/null; then
  return 0
fi

function set_poshcontext {
  unset POSH_PRECOMMIT_MISSING
  local GIT_ROOT
  GIT_ROOT=$(git rev-parse --show-toplevel 2> /dev/null)
  if [[ -n "${GIT_ROOT}" ]] && [[ -f "${GIT_ROOT}/.pre-commit-config.yaml" ]] && [[ ! -f "${GIT_ROOT}/.git/hooks/pre-commit" ]]; then
    export POSH_PRECOMMIT_MISSING=true
  fi
}

if command -v oh-my-posh &> /dev/null; then
  eval "$(oh-my-posh init "${CURRENT_SHELL}" --config "${SHELL_CONFIG_PATH}/edubxb.omp.toml")"
fi
