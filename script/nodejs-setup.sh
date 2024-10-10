#!/bin/bash

# Node.jsのセットアップ
# https://nodejs.org/en/download/package-manager

# installs nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# 上記インストール中に.bachrcに必要な設定を追加するため、それを反映させる
source ~/.bashrc

echo "download and install Node.js"
nvm install 20

echo "verifies the right Node.js version is in the environment"
node -v # should print `v20.17.0`

echo "verifies the right npm version is in the environment"
npm -v # should print `10.8.2`

# `npm`: Node.jsのライブラリやモジュールのインストール・管理をするためのツール。
# `nvm`: 複数のNode.jsのバージョンを管理・切り替えるためのツール。
