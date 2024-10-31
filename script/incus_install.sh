#!/bin/bash

set -e

# 最新のリリースをインストール
sudo curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc
sudo sh -c 'cat <<EOF > /etc/apt/sources.list.d/zabbly-incus-stable.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/stable
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc
EOF'

sudo apt-get update
sudo apt-get install -y incus
incus version

# ミニマル設定で初期化
sudo incus admin init --minimal

# sudoなしでincusコマンド実行できるように
# 現在のユーザーをincusグループに追加
sudo gpasswd -a $USER incus

echo "現在のユーザーにincusグループを適用するため再ログインしてください"

