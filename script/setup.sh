#!/bin/bash
# Ubuntu デスクトップの初期セットアップ
# - 追加のパッケージ
# - エイリアス設定

set -e

# 追加パッケージのインストール
package_install.sh

# Oh My Bash インストール
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

# .bashrc is created by OhMyBash, add some Alias.
echo "" >> $HOME/.bashrc
echo "# Alias" >> $HOME/.bashrc
echo "alias py=python3" >> $HOME/.bashrc
echo "alias python=python3" >> $HOME/.bashrc
mkdir -p $HOME/.local/bin
echo 'export PATH="$PATH:$HOME/.local/bin"' >> $HOME/.bashrc

