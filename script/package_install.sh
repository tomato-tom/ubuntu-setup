#!/bin/bash -e

# 追加でインストールするパッケージ

sudo apt-get install curl tree git -y
sudo apt-get install fdupes vim-gtk3 -y
#sudo apt-get install wireshark -y

#snap install joplin-desktop
sudo snap install vlc
sudo snap install yt-dlp

# Oh My Bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
