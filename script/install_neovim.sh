#!/bin/bash
# script/install_neovim.sh
# Installing and setup Neovim
# Ubuntu

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"
LOGGER="$PROJECT_ROOT/lib/logger.sh"
[ -f "$LOGGER" ] && source $LOGGER $0 || exit 1

# Neovim のインストール
if ! command -v nvim &>/dev/null; then
    log info "Installing Neovim..."
    sudo apt update
    sudo apt install -y neovim
else
    log info "Neovim is already installed."
fi

# Neovim のパスを確認
NVIM_PATH="$(command -v nvim)"
if [ -z "$NVIM_PATH" ]; then
    log error "Neovim is not installed or not found in PATH."
    exit 1
fi

log info "Neovim found at: $NVIM_PATH"

update_vi() {
    log info "Setting up 'vi' to use Neovim via update-alternatives..."
    sudo update-alternatives --install /usr/bin/vi vi "$NVIM_PATH" 100
    sudo update-alternatives --set vi "$NVIM_PATH"
    log info "'vi' has been set to use Neovim."
}

# vi コマンドをnvimに設定
if command -v vi &>/dev/null; then
    log info "'vi' command is already installed."
    
    # 現在の設定を確認（update-alternatives で管理されている場合）
    if update-alternatives --query vi &>/dev/null; then
        CURRENT_VI=$(update-alternatives --query vi 2>/dev/null | awk -F': ' '/Value:/ {print $2}')
        
        if [ "$CURRENT_VI" = "$NVIM_PATH" ]; then
            log info "'vi' is already set to Neovim via update-alternatives."
        else
            update_vi
        fi
    else
        # update-alternatives で管理されていない場合
        CURRENT_VI=$(readlink -f "$(command -v vi)")
        if [ "$CURRENT_VI" = "$NVIM_PATH" ]; then
            log info "'vi' is already linked to Neovim."
        else
            update_vi
        fi
    fi
else
    update_vi
fi

# 設定の確認
log info "Current 'vi' points to: $(readlink -f "$(command -v vi)")"
log info "Current 'vi' version: $(vi --version | head -n 1)"

# Neovim configuration
CONFIG_SOURCE="$PROJECT_ROOT/dotfiles/init.lua"
CONFIG_PATH="$HOME/.config/nvim"

mkdir -p "$CONFIG_PATH"

# 設定ファイルのコピー
if [ -f "$CONFIG_SOURCE" ]; then
    log info "Copying Neovim configuration file..."
    cp -u "$CONFIG_SOURCE" "$CONFIG_PATH/init.lua"
    log info "Neovim configuration copied to $CONFIG_PATH/init.lua"
else
    log warn "Configuration file not found at $CONFIG_SOURCE"
fi

log info "Neovim setup completed successfully!"
