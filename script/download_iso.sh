#!/bin/bash

# 設定
MIRROR_URL="https://jp.mirror.coganng.com/ubuntu-cdimage/jammy"
ISO_NAME="ubuntu-22.04.5-live-server-amd64.iso"
SHA_FILE="SHA256SUMS"
GPG_FILE="SHA256SUMS.gpg"

# 必要なツールの確認
command -v wget >/dev/null 2>&1 || { echo "wgetが必要です"; exit 1; }
command -v gpg >/dev/null 2>&1 || { echo "GPGが必要です"; exit 1; }

# ファイルダウンロード
echo "ダウンロードを開始します..."
#wget -nc "${MIRROR_URL}/${ISO_NAME}"
wget -nc "${MIRROR_URL}/${SHA_FILE}"
wget -nc "${MIRROR_URL}/${GPG_FILE}"

# Ubuntu公開鍵の取得（初回のみ）
if ! gpg --list-keys "Ubuntu CD Image Automatic Signing Key" >/dev/null 2>&1; then
    echo "UbuntuのGPG鍵をインポートします..."
    gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys "843938DF228D22F7B3742BC0D94AA3F0EFE21092"
fi

# GPG署名の検証
echo "署名を検証します..."
if gpg --verify "${GPG_FILE}" "${SHA_FILE}"; then
    echo "✅ 署名が有効です（Ubuntu公式のビルド）"
else
    echo "❌ 署名が無効です！"
    exit 1
fi

# チェックサムの検証
echo "チェックサムを検証します..."
sha256sum -c --ignore-missing < "${SHA_FILE}"

echo "すべての検証が完了しました"

