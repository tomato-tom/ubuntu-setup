#!/bin/bash

# キーボードのcapslockをcontrolにマッピング
# Ubuntu 22.04~24.04
# Apple Macbook Air 6.1
# root実行

# ベンダーIDとプロダクトIDを取得
vendor_id=$(lsusb | grep "Apple Internal Keyboard / Trackpad" | awk '{print $6}' | cut -d':' -f1 | tr '[:lower:]' '[:upper:]')
product_id=$(lsusb | grep "Apple Internal Keyboard / Trackpad" | awk '{print $6}' | cut -d':' -f2)
echo vendorID: $vendor_id
echo productID: $product_id

# 設定ファイル作成
cat << EOF > /etc/udev/hwdb.d/90-custom-keyboard.hwdb
evdev:input:b*v${vendor_id}p${product_id}*
  KEYBOARD_KEY_70039=leftctrl
EOF

# 設定を適用
systemd-hwdb update
udevadm trigger

# 確認
# 設定反映されるまでいくらかタイムラグある
# 再起動は不要
udevadm info /dev/input/by-path/*-usb-*-kbd | grep KEYBOARD_KEY

