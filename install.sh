#!/usr/bin/env bash

set -euo pipefail

dotfiles_dir="$HOME/dotfiles"

if [[ ! -d "$dotfiles_dir" ]]; then
  echo "Expected dotfiles at $dotfiles_dir" >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo 'Install Homebrew from https://brew.sh, then rerun this script.' >&2
  exit 1
fi

brew bundle --file "$dotfiles_dir/Brewfile"

zsh_loader='# dotfiles'
if [[ ! -f "$HOME/.zshrc" ]] || ! grep -Fq "$zsh_loader" "$HOME/.zshrc"; then
  {
    printf '\n%s\n' "$zsh_loader"
    printf 'for module in aliases history completions fzf zoxide file-search vi-mode prompt-history shell-assist; do\n'
    # shellcheck disable=SC2016
    printf '  source "$HOME/dotfiles/zsh/${module}.zsh"\n'
    printf 'done\n'
  } >> "$HOME/.zshrc"
fi

git_include="path = $dotfiles_dir/gitconfig"
if [[ ! -f "$HOME/.gitconfig" ]] || ! grep -Fq "$git_include" "$HOME/.gitconfig"; then
  git config --global include.path "$dotfiles_dir/gitconfig"
fi

link_config() {
  source_file="$1"
  target_file="$2"
  mkdir -p "$(dirname "$target_file")"
  if [[ ! -e "$target_file" && ! -L "$target_file" ]]; then
    ln -s "$source_file" "$target_file"
  elif [[ -L "$target_file" && "$(readlink "$target_file")" == "$source_file" ]]; then
    :
  else
    echo "Leaving $target_file unchanged because it already contains something." >&2
  fi
}

link_config "$dotfiles_dir/config/nvim" "$HOME/.config/nvim"
link_config "$dotfiles_dir/config/tmux.conf" "$HOME/.tmux.conf"
link_config "$dotfiles_dir/config/starship.toml" "$HOME/.config/starship.toml"
link_config "$dotfiles_dir/config/atuin.toml" "$HOME/.config/atuin/config.toml"
link_config "$dotfiles_dir/config/ghostty/config.ghostty" \
  "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"

if [[ ! -d "$HOME/.tmux/plugins/tpm/.git" ]]; then
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || true

"$dotfiles_dir/macos.sh"

echo 'done'
