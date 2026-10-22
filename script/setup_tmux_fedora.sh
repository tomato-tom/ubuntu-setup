#!/bin/bash

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"
LOGGER="$PROJECT_ROOT/lib/logger.sh"
[ -f "$LOGGER" ] && source "$LOGGER" "$0" || exit 1

# tmux のインストール（Fedora: dnf）
if ! command -v tmux >/dev/null 2>&1; then
    log info "Installing tmux..."
    sudo dnf install -y tmux
else
    log info "tmux is already installed"
fi

# 設定
target_file="$HOME/.tmux.conf"
source_file="$PROJECT_ROOT/dotfiles/tmux.conf"

# 設定を反映
if [ -f "$source_file" ]; then
    log info "Copying $source_file to $target_file..."
    cp -f "$source_file" "$target_file"
    # tmux サーバが起動中なら即時反映、未起動なら次回起動時に読まれる
    if tmux info >/dev/null 2>&1; then
        tmux source-file "$target_file"
        log info "tmux configuration reloaded"
    else
        log info "tmux server not running; config will apply on next start"
    fi
else
    log error "File not found: $source_file"
    exit 1
fi

log info "Setup completed successfully!"
