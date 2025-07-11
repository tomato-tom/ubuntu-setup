#!/bin/bash

# Neovim のインストール
echo "Installing Neovim..."
sudo apt update
sudo apt install -y neovim || { echo "Failed to install Neovim"; exit 1; }

# Neovim のパスを確認
NVIM_PATH="$(which nvim)"
if [ -z "$NVIM_PATH" ]; then
    echo "Neovim is not installed or not found in PATH."
    exit 1
fi

# vi コマンドの存在確認と設定
if command -v vi &>/dev/null; then
    echo "'vi' command is already installed."
    VI_PATH="$(which vi)"
    # update-alternatives を使って vi を nvim に設定
    echo "Setting up 'vi' to use Neovim via update-alternatives..."
    sudo update-alternatives --install $VI_PATH vi $NVIM_PATH 100 || { echo "Failed to install alternative"; exit 1; }
    sudo update-alternatives --set vi $NVIM_PATH || { echo "Failed to set alternative"; exit 1; }
else
    echo "'vi' command is not installed. Creating a symbolic link..."
    # vi が存在しない場合は /usr/bin/vi にシンボリックリンクを作成
    VI_PATH="/usr/bin/vi"
    sudo ln -sf "$NVIM_PATH" "$VI_PATH" || { echo "Failed to create symbolic link"; exit 1; }
fi

# 確認
echo "Current 'vi' version:"
vi --version | head -n 1

# Neovim 設定ディレクトリの作成
CONFIG_SOURCE="$HOME/git/ubuntu-setup/config/nvim_init.lua"
CONFIG_PATH="$HOME/.config/nvim"

echo "Creating Neovim configuration directory..."
mkdir -p "$CONFIG_PATH"

# 設定ファイルのコピー
if [ -f "$CONFIG_SOURCE" ]; then
    echo "Copying Neovim configuration file..."
    cp "$CONFIG_SOURCE" "$CONFIG_PATH/init.lua"
else
    echo "Configuration file not found at $CONFIG_SOURCE"
    exit 1
fi

echo "Setup completed successfully!"

