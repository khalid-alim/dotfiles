if [[ -o interactive ]]; then
  autoload -Uz compinit
  zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
  if [[ ! -f "$zcompdump" || -n "$(find "$zcompdump" -mtime +0 -print 2>/dev/null)" ]]; then
    compinit
  else
    compinit -C
  fi
  zstyle ':completion:*' menu select
  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
fi
