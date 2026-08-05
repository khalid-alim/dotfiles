if [[ -o interactive ]]; then
  bindkey -v
  export KEYTIMEOUT=1
  bindkey -M viins '^?' backward-delete-char
  bindkey -M viins '^W' backward-kill-word
  bindkey -M viins '^A' beginning-of-line
  bindkey -M viins '^E' end-of-line
  autoload -Uz edit-command-line
  zle -N edit-command-line
  bindkey -M vicmd v edit-command-line
fi
