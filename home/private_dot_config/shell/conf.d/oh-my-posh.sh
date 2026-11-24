## Oh My Posh ##
if command -v oh-my-posh &> /dev/null; then
  eval "$(oh-my-posh init "${CURRENT_SHELL}" --config "${SHELL_CONFIG_PATH}/edubxb.omp.toml")"
fi

# Must be defined after `oh-my-posh init`, which declares an empty placeholder.
function set_poshcontext {
  unset POSH_GIT_HOOKS_MISSING POSH_AWS_SSO_LEFT
  # `--git-path hooks` resolves the shared hooks dir for worktrees (where `.git` is a file)
  # and honours `core.hooksPath`.
  local git_paths git_root hooks_dir cfg
  if command -v git &> /dev/null; then
    git_paths=$(git rev-parse --path-format=absolute --show-toplevel --git-path hooks 2> /dev/null)
  fi
  git_root=${git_paths%%$'\n'*}
  hooks_dir=${git_paths#*$'\n'}
  if [[ -n "${git_root}" ]]; then
    if [[ -f "${git_root}/.pre-commit-config.yaml" ]] && [[ ! -f "${hooks_dir}/pre-commit" ]]; then
      export POSH_GIT_HOOKS_MISSING=true
    fi
    # Lefthook installs one script per configured hook; each one mentions "lefthook".
    for cfg in {,.}lefthook.{yml,yaml,json,jsonc,toml} .config/lefthook.{yml,yaml,json,jsonc,toml}; do
      if [[ -f "${git_root}/${cfg}" ]]; then
        grep -rqs lefthook "${hooks_dir}" || export POSH_GIT_HOOKS_MISSING=true
        break
      fi
    done
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
