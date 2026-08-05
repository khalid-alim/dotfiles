if [[ -o interactive ]]; then
  autosuggest=/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  highlight=/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  [[ -r "$autosuggest" ]] && source "$autosuggest"
  [[ -r "$highlight" ]] && source "$highlight"
  unset autosuggest highlight
fi
