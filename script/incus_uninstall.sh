#!/bin/bash

# エラーが発生したら即座に終了
#set -e

# root権限チェック
if [ "$EUID" -ne 0 ]; then
    echo "このスクリプトはroot権限で実行する必要があります。"
    echo "sudo $0 を実行してください。"
    exit 1
fi

echo "incusのアンインストールを開始します..."

# サービスの停止
echo "サービスを停止中..."
systemctl stop incus.service || true
systemctl stop incus.socket || true
systemctl stop incus-user.service || true
systemctl stop incus-user.socket || true
systemctl stop incus-lxcfs.service || true

# デーモンのリロード
echo "systemdデーモンをリロード中..."
systemctl daemon-reload

# パッケージの削除
echo "パッケージを削除中..."
apt purge -y incus || true
apt autoremove -y || true

# 設定ファイルとディレクトリの削除
echo "設定ファイルとディレクトリを削除中..."
rm -rf /home/*/.config/incus
rm -rf /home/*/.cache/incus
rm -rf /etc/logrotate.d/incus
rm -rf /etc/default/incus
rm -rf /var/log/incus
rm -rf /var/lib/incus
rm -rf /var/cache/incus
rm -rf /root/.config/incus
rm -rf /root/.cache/incus
rm -rf /run/incus
rm -rf /run/lxc/lock/var/lib/incus

# Zabblyのリポジトリ設定の削除
echo "リポジトリ設定を削除中..."
rm -f /etc/apt/keyrings/zabbly.asc
rm -f /etc/apt/sources.list.d/zabbly-incus-stable.sources

# ネットワークブリッジの削除
echo "ネットワークブリッジを削除中..."
for bridge in $(ip link show | grep 'incusbr' | cut -d: -f2 | awk '{print $1}'); do
    ip link delete $bridge || true
done

# incusグループを削除
groupdel incus

echo "アンインストール完了"
