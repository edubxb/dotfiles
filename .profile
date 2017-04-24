if [ -d "${HOME}/.local/bin" ]; then
  PATH="${HOME}/.local/bin:${PATH}"
fi

if [ -d "${HOME}/.npm/bin" ]; then
  PATH="${HOME}/.npm/bin:${PATH}"
fi
