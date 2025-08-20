#!/bin/bash
#
# ------------------------------------------
# Ubuntu デスクトップの初期セットアップ
# - 追加のパッケージ
# - 日本語環境
# - neovim, tmux, obsidian
# - grub
# - エイリアス設定
# ------------------------------------------

set -e

# 各ツールのセットアップ・スクリプトを実行
[ -f package_install.sh ] && package_install.sh
[ -f keymap.sh ]          && keymap.sh
[ -f fcitx5setup.sh ]     && fcitx5setup.sh
[ -f install_neovim.sh ]  && install_neovim.sh
[ -f obsidian_update.sh ] && obsidian_update.sh
[ -f setup_tmux.sh ]      && setup_tmux.sh
[ -f update_grub.sh ]     && update_grub.sh

# Oh My Bash インストール
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

# .bashrc is created by OhMyBash, add some Alias.
if ! grep '# Alias' $HOME/.bashrc; then
    echo "" >> $HOME/.bashrc
    echo "# Alias" >> $HOME/.bashrc
    echo "alias py=python3" >> $HOME/.bashrc
    echo "alias python=python3" >> $HOME/.bashrc
    mkdir -p $HOME/.local/bin
    echo 'export PATH="$PATH:$HOME/.local/bin"' >> $HOME/.bashrc
fi

