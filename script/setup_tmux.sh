#!/bin/bash

set -e

if ! command -v tmux; then
    sudo apt-get update
    sudo apt-get install -y tmux
fi

# 設定
target_file="$HOME/.tmux.conf"
source_file="$(dirname "${BASH_SOURCE[0]}")/../dotfiles/tmux.conf"

# 設定を反映
[ -f "$source_file" ] && {
    cp -f "$source_file" "$target_file"
    tmux source-file $target_file
} || exit "$?"

echo "Setup completed successfully!"

