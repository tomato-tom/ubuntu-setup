#!/bin/bash

sudo apt update
sudo apt install -y neovim openssh-server git debootstrap systemd-container tmux

# デフォルトエディタをvimに設定
sudo update-alternatives --set editor /usr/bin/nvim

# SSH
# rootログインとパスワード認証を無効化
sudo sed -i 's/^#PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
# 競合する設定ファイルを削除
sudo rm /etc/ssh/sshd_config.d/50-cloud-init.conf
sudo systemctl disable --now cloud-init
sudo systemctl restart ssh 

