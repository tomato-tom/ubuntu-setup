#!/bin/bash

# LXDをインストール
if ! sudo snap install lxd; then
    echo "LXD is already installed. Refreshing..."
    sudo snap refresh lxd
else
    echo "LXD has been installed successfully."
fi

# 現在のユーザーをLXDグループに追加
sudo usermod -aG lxd "$USER"

# LXDの初期設定
sudo lxd init --minimal

# コンテナの作成と基本操作
echo "Launch a container called mycontainer..."
sudo lxc launch ubuntu:24.04 mycontainer
sudo lxc list
sudo lxc exec mycontainer -- cat /etc/*release

# コンテナの停止と削除
echo "Delete the container"
sudo lxc stop mycontainer
sudo lxc delete mycontainer

# ユーザーに再ログインを促す
echo "User $USER has been added to the lxd group. Please log out and log back in for changes to take effect."

