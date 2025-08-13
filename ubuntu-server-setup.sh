#!/bin/bash

# vimがインストールされていない場合はインストール
if ! command -v vim &> /dev/null; then
    sudo apt update
    sudo apt install -y vim
fi

# デフォルトエディタをvimに設定
sudo update-alternatives --set editor /usr/bin/vim.basic

