#!/bin/bash -e

# Ubuntu24.04
# mozcを設定ファイルに突っ込めれば完璧

# パッケージのアップグレード
sudo apt-get update
#sudo apt-get upgrade -y

# fcitx5と必要なパッケージをインストール
sudo apt-get install -y fcitx5 fcitx5-mozc fcitx5-config-qt

# fcitx5を入力メソッドに設定
sudo im-config -n fcitx5

# ~/.profileにfcitx5の自動起動設定を追加
if ! grep -q "fcitx5" "$HOME/.profile"; then
    echo "fcitx5 > /dev/null 2>&1 &" >> "$HOME/.profile"
fi

# .profileを再読み込みして、即座に反映
source "$HOME/.profile"


# fcitx5の設定ファイルを作成する
# 未検証***
CONFIG_FILE="$HOME/.config/fcitx5/profile"

cat <<EOF > $CONFIG_FILE
[Groups/0]
# Group Name
Name=Default
# Layout
Default Layout=us
# Default Input Method
DefaultIM=mozc

[Groups/0/Items/0]
# Name
Name=keyboard-us
# Layout
Layout=

[Groups/0/Items/1]
# Name
Name=mozc
# Layout
Layout=

[GroupOrder]
0=Default
EOF


# fcitx5を再起動して設定を反映させる
pkill -USR1 fcitx5

