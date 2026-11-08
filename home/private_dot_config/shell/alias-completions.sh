## alias completions ##
if [[ -n "${ZSH_VERSION:-}" ]]; then
  for alias_name in ${(k)aliases}; do
    alias_value="${aliases[${alias_name}]}"
    command_name="${alias_value%% *}"
    completion="${_comps[${command_name}]-}"

    if [[ -z "${completion}" ]]; then
      autoload -Uz "_${command_name}" 2> /dev/null
      completion="_${command_name}"
    fi

    if (( $+functions[${completion}] )); then
      compdef "${completion}" "${alias_name}"
    fi
  done
fi
