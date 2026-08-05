export EDITOR='nvim'
export VISUAL='nvim'
alias vim='nvim'
alias t='tmux new-session -A -s main'
alias ta='tmux attach-session'
alias p='python3'
alias ga='git add'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git pull --ff-only'
if command -v eza >/dev/null 2>&1; then
  alias ll='eza --long --all --group-directories-first --git'
  alias lt='eza --tree --level=2 --group-directories-first'
else
  alias ll='ls -lah'
  alias lt='find . -maxdepth 2 -print'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias path='printf "%s\n" "${PATH//:/\\n}"'

alias brews='brew search'
alias brewu='brew update && brew upgrade && brew cleanup'
