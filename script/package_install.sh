#!/bin/bash -e

sudo apt-get update

# 追加でインストールするパッケージ
sudo apt-get install curl tree git -y
sudo apt-get install fdupes vim-gtk3 -y
sudo apt-get install xclip -y

sudo systemctl daemon-reload

# Oh My Bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

# OhMyBashで.bashrc作成されるから、その後Alias追記
echo "" >> $HOME/.bashrc
echo "# Alias" >> $HOME/.bashrc
echo "alias py=python3" >> $HOME/.bashrc
echo "alias python=python3" >> $HOME/.bashrc
echo 'alias clip="xclip -selection clipboard"' >> $HOME/.bashrc
echo "alias ull=ultralist" >> $HOME/.bashrc
echo 'export PATH="$PATH:$HOME/.local/bin"' >> $HOME/.bashrc

