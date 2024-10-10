#!/bin/bash

# 現在のUEFIブートエントリを確認
efibootmgr
echo

# バックアップを作成
sudo cp /etc/default/grub /etc/default/grub.bak

# 次回も現在と同じOS起動
sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub
sudo sed -i '/^GRUB_DEFAULT=/aGRUB_SAVEDEFAULT=true' /etc/default/grub
# grubメニューのタイムアウト10秒
sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=10/' /etc/default/grub
sudo sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub

# 設定を反映
sudo update-grub

echo "GRUB設定を更新しました。再起動してください。"

