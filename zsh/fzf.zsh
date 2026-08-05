if [[ -o interactive && -t 0 && -t 1 ]] && command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
