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

