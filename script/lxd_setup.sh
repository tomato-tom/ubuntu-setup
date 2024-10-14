#!/bin/bash
# LXDインストールから動作確認まで

# LXDをインストール
if ! sudo snap install lxd; then
    echo "LXD is already installed. Refreshing..."
    sudo snap refresh lxd
else
    echo "LXD has been installed successfully."
fi

# 現在のユーザーをLXDグループに追加
sudo usermod -aG lxd "$USER"
newgrp lxd
getent group lxd | grep "$USER"

# LXDの初期設定
lxd init --minimal

# Ubuntu 24.04のイメージ確認
lxc image list ubuntu:
lxc image list ubuntu: 24.04 architecture=$(uname -m)

# コンテナの作成と基本操作
echo "Launch a container called mycontainer..."
lxc launch ubuntu:24.04 mycontainer
lxc list
lxc exec mycontainer -- cat /etc/*release

# コンテナの停止と削除
echo "Delete the container"
lxc stop mycontainer
lxc delete mycontainer

