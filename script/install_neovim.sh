#!/bin/bash
# script/install_neovim.sh
# Installing and setup Neovim
# Ubuntu debian archlinux Fedora

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"
LOGGER="$PROJECT_ROOT/lib/logger.sh"
[ -f "$LOGGER" ] && source $LOGGER $0 || exit 1

# --- OS 検出 ---
detect_os() {
    if [ -f /etc/fedora-release ]; then
        if [ -f /run/ostree-booted ]; then
            echo "silverblue"
        else
            echo "fedora"
        fi
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/arch-release ]; then
        echo "arch"
    else
        echo "unknown"
    fi
}
OS="$(detect_os)"
log info "Detected OS: $OS"

# --- パッケージ操作の抽象化 ---
pkg_install_neovim() {
    case "$OS" in
        silverblue)
            log warn "Run inside toolbox: 'toolbox enter' then re-run $0"
            exit 1
            ;;
        fedora)
            sudo dnf install -y neovim
            ;;
        debian)
            sudo apt update && sudo apt install -y neovim
            ;;
        arch)
            sudo pacman -Syu --needed --noconfirm neovim
            ;;
        *)
            log error "Unsupported OS: $OS"; exit 1
            ;;
    esac
}

# Neovim のインストール
if ! command -v nvim &>/dev/null; then
    log info "Installing Neovim..."
    pkg_install_neovim
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

# --- vi を nvim に向ける（環境別） ---
if command -v update-alternatives &>/dev/null; then
    # --- alternatives があるOS（Fedora / Debian / Ubuntu ---
    if update-alternatives --query vi &>/dev/null; then
        current="$(update-alternatives --query vi 2>/dev/null | awk -F': ' '/Value:/ {print $2}')"
        if [ "$current" = "$NVIM_PATH" ]; then
            log info "'vi' is already set to Neovim via update-alternatives."
        else
            sudo update-alternatives --install /usr/bin/vi vi "$NVIM_PATH" 100
            sudo update-alternatives --set vi "$NVIM_PATH"
            log info "'vi' has been set to Neovim via update-alternatives."
        fi
    else
        # alternatives はあるが vi 未登録
        sudo update-alternatives --install /usr/bin/vi vi "$NVIM_PATH" 100
        sudo update-alternatives --set vi "$NVIM_PATH"
        log info "Registered and set 'vi' to Neovim via update-alternatives."
    fi
else
    # --- alternatives がないOS（Arch） ---
    if [ "$(readlink -f /usr/local/bin/vi 2>/dev/null)" = "$NVIM_PATH" ]; then
        log info "'vi' is already linked to Neovim at /usr/local/bin/vi."
    else
        sudo ln -sf "$NVIM_PATH" /usr/local/bin/vi
        log info "Linked /usr/local/bin/vi -> $NVIM_PATH"
    fi
fi

# 設定の確認
log info "Current 'vi' points to: $(readlink -f "$(command -v vi)")"
log info "Current 'vi' version: $(vi --version | head -n 1)"

# Neovim configuration
CONFIG_DIR="$HOME/.config/nvim"
mkdir -p "$CONFIG_DIR"

copy_file() {
    local source="$1"
    local target="$2"
    log info "Copying $source..."
    if [ -f "$source" ]; then
        install -Dm644 "$source" "$target"
        log info "Copied to $target"
    else
        log warn "File not found:$source"
    fi
}

source_file="$PROJECT_ROOT/dotfiles/init.lua"
copy_file "$source_file" "$CONFIG_DIR/$(basename "$source_file")"

source_file="$PROJECT_ROOT/dotfiles/format_table.lua"
copy_file "$source_file" "$CONFIG_DIR/lua/$(basename "$source_file")"

log info "Neovim setup completed successfully!"

