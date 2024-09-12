#!/bin/bash -e
# Ubuntu24.04
# OSインストール時のfcitx5セットアップ
# だいたいOK

# パッケージのアップグレード
sudo apt-get update

# fcitx5と必要なパッケージをインストール
sudo apt-get install -y fcitx5 fcitx5-mozc fcitx5-config-qt

# fcitx5を入力メソッドに設定
sudo im-config -n fcitx5

# ~/.profileにfcitx5の自動起動設定を追加
if ! grep -q "fcitx5" "$HOME/.profile"; then
    echo "fcitx5 > /dev/null 2>&1 &" >> "$HOME/.profile"
fi

source "$HOME/.profile"

# gnome特有の環境変数
# https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland#GNOME
if ! grep -q "# fcitx5" "$HOME/.bashrc"; then
cat << EOF >> $HOME/.bashrc
# fcitx5
export XMODIFIERS=@im=fcitx
export QT_IM_MODULE=fcitx
export GTK_IM_MODULE=fcitx
EOF
fi

source "$HOME/.bashrc"

sleep 1

# fcitx5の設定ファイルを作成する
#mkdir -p "$HOME/.config/fcitx5" # fcitx5のインストール時に作成されてる

CONFIG_DIR="$HOME/.config/fcitx5"
CONFIG_FILE="$CONFIG_DIR/profile"
BACKUP_FILE="$CONFIG_DIR/profile.bak"

# Backup existing configuration
if [ -f "$CONFIG_FILE" ]; then
    echo "Backing up existing configuration..."
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo "Backup created at $BACKUP_FILE"
else
    echo "No existing configuration found to back up."
    touch $CONFIG_FILE
fi

echo "Creating new configuration..."

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

# Restoring the backup if needed
# cp "$BACKUP_FILE" "$CONFIG_FILE"
# echo "Configuration restored from backup."

echo "Restart Fcitx5..."
fcitx5 -r &

