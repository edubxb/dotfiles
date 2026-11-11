## alias completions ##
if [[ -n "${ZSH_VERSION:-}" ]]; then
  while IFS= read -r alias_definition; do
    alias_name=${alias_definition#alias }
    alias_name=${alias_name%%=*}
    alias_value=${alias_definition#*=}
    alias_value=${alias_value#\'}
    alias_value=${alias_value%\'}
    command_name="${alias_value%% *}"
    completion=${_comps[$command_name]-}

    if [[ -z "${completion}" ]]; then
      autoload "_${command_name}" 2> /dev/null
      completion="_${command_name}"
    fi

    if [[ -n "${completion}" ]]; then
      compdef "${completion}" "${alias_name}"
    fi
  done < <(alias -L)
fi
