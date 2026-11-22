## Oh My Posh ##
if ! command -v git &> /dev/null; then
  return 0
fi

if command -v oh-my-posh &> /dev/null; then
  eval "$(oh-my-posh init "${CURRENT_SHELL}" --config "${SHELL_CONFIG_PATH}/edubxb.omp.toml")"
fi

# Must be defined after `oh-my-posh init`, which declares an empty placeholder.
function set_poshcontext {
  unset POSH_PRECOMMIT_MISSING POSH_AWS_SSO_LEFT
  local GIT_ROOT
  GIT_ROOT=$(git rev-parse --show-toplevel 2> /dev/null)
  if [[ -n "${GIT_ROOT}" ]] && [[ -f "${GIT_ROOT}/.pre-commit-config.yaml" ]] && [[ ! -f "${GIT_ROOT}/.git/hooks/pre-commit" ]]; then
    export POSH_PRECOMMIT_MISSING=true
  fi

  local sso_session sso_cache left
  if [[ -n "${AWS_PROFILE}" ]]; then
    sso_session=$(sed -n "/^\[profile ${AWS_PROFILE}\]\$/,/^\[/ s/^sso_session *= *//p" \
      "${AWS_CONFIG_FILE:-${HOME}/.aws/config}" 2> /dev/null)
  fi
  # The AWS CLI names the SSO token cache file after the SHA-1 of the session name.
  [[ -n "${sso_session}" ]] && sso_cache="${HOME}/.aws/sso/cache/$(echo -n "${sso_session}" | sha1sum | cut -d' ' -f1).json"

  if [[ -n "${sso_cache}" ]] && [[ -f "${sso_cache}" ]]; then
    left=$(( $(date -d "$(jq -r .expiresAt "${sso_cache}")" +%s) - $(date +%s) ))
    if (( left > 0 )); then
      export POSH_AWS_SSO_LEFT="$(( left / 3600 ))h$(( left % 3600 / 60 ))m"
    else
      export POSH_AWS_SSO_LEFT=expired
    fi
  fi
}
