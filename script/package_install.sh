#!/bin/bash -e

# Packages to install for now
sudo apt-get update
sudo apt-get install curl tree git htop tldr fzf -y
sudo apt-get install fdupes vim-gtk3 xclip -y
sudo apt-get install debootstrap inotify-tools -y
sudo systemctl daemon-reload

# Oh My Bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

# .bashrc is created by OhMyBash, add some Alias.
echo "" >> $HOME/.bashrc
echo "# Alias" >> $HOME/.bashrc
echo "alias py=python3" >> $HOME/.bashrc
echo "alias python=python3" >> $HOME/.bashrc
echo 'alias clip="xclip -selection clipboard"' >> $HOME/.bashrc
echo "alias ull=ultralist" >> $HOME/.bashrc
echo 'export PATH="$PATH:$HOME/.local/bin"' >> $HOME/.bashrc

