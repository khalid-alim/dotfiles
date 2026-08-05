if [[ -o interactive ]]; then
  command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
  command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh --disable-up-arrow)"
fi
