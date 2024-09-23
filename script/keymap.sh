#!/bin/bash

# キーボードのcapslockをcontrolにマッピング
# Ubuntu 22.04~24.04
# Apple Macbook Air 6.1

# スクリプトがroot権限で実行されているかチェック
if [ "$(id -u)" -ne 0 ]; then
    echo "エラー: このスクリプトはroot権限で実行する必要があります。"
    exit 1
fi

# デバイスリストを表示
echo "接続されているキーボードデバイス:"
keyboard_devices=$(lsusb | grep "Keyboard")

# キーボードデバイスの行数をチェック
num_devices=$(echo "$keyboard_devices" | wc -l)

if [ "$num_devices" -eq 0 ]; then
    echo "エラー: キーボードデバイスが見つかりません。"
    exit 1
elif [ "$num_devices" -gt 1 ]; then
    echo "エラー: 複数のキーボードデバイスが見つかりました。"
    echo "$keyboard_devices"
    exit 1
fi

# ベンダーIDとプロダクトIDを取得
vendor_id=$(echo "$keyboard_devices" | awk '{print $6}' | cut -d':' -f1 | tr '[:lower:]' '[:upper:]')
product_id=$(echo "$keyboard_devices" | awk '{print $6}' | cut -d':' -f2 | tr '[:lower:]' '[:upper:]')

# デバイス名を取得
device_name=$(echo "$keyboard_devices" | awk '{for (i=7; i<=NF; i++) printf $i " "; print ""}')

echo vendorID: $vendor_id
echo productID: $product_id
echo デバイス名: $device_name

# 使用可能な設定ファイル番号を探す
for i in {90..99}; do
    hwdb_file="/etc/udev/hwdb.d/${i}-custom-keyboard.hwdb"
    if [ ! -f "$hwdb_file" ]; then
        echo "設定ファイルを作成: $hwdb_file"
        cat << EOF > "$hwdb_file"
evdev:input:b*v${vendor_id}p${product_id}*
  KEYBOARD_KEY_70039=leftctrl
EOF
        break
    fi
done

# 設定を適用
systemd-hwdb update
udevadm trigger

# 設定確認
# 設定反映されるまでいくらかタイムラグある
echo 設定を反映してます...
sleep 3
udevadm info /dev/input/by-path/*-usb-*-kbd | grep KEYBOARD_KEY

