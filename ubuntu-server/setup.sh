#!/bin/bash

sudo apt update
sudo apt install -y neovim openssh-server git systemd-container tmux screen iputils-ping

# デフォルトエディタをvimに設定
sudo update-alternatives --set editor /usr/bin/nvim

# SSH
# rootログインとパスワード認証を無効化
# 公開鍵入れてから
sudo sed -i 's/^#PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config

# 競合する設定ファイルを削除
# ミニマル・インストール時はない
if [ -f /etc/ssh/sshd_config.d/50-cloud-init.conf ]; then
    sudo rm /etc/ssh/sshd_config.d/50-cloud-init.conf
fi

if systemctl is-enabled clout-init; then
    sudo systemctl disable --now cloud-init
fi

sudo systemctl restart ssh 

