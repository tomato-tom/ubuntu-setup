#!/bin/bash

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"
LOGGER="$PROJECT_ROOT/lib/logger.sh"
[ -f "$LOGGER" ] && source $LOGGER $0 || exit 1

if ! command -v tmux; then
    sudo apt-get update
    sudo apt-get install -y tmux
fi

# 設定
target_file="$HOME/.tmux.conf"
source_file="$PROJECT_ROOT/dotfiles/tmux.conf"

# 設定を反映
[ -f "$source_file" ] && {
    log info "Copying "$source_file" to "$target_file"..."
    cp -f "$source_file" "$target_file"
    tmux source-file $target_file
} || exit "$?"

log info "Setup completed successfully!"

