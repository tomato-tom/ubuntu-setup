#!/bin/bash

set -e

if command -v tmux; then
    echo tmux is already installed
else
    sudo apt-get update
    sudo apt-get install -y tmux
fi

# Oh my tmux! のセットアップ
cd ~
if [ ! -d ".tmux" ]; then
    git clone --single-branch https://github.com/gpakosz/.tmux.git
else
    exit 1
fi
ln -sf .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .

# 追加設定
conf_file=".tmux.conf.local"
if ! grep 'Custom settings' -q "$conf_file"; then
    echo "# Custom settings" >> "$conf_file"
    echo "# Emojis and the like" >> "$conf_file"
    echo "set -g utf8 on" >> "$conf_file"
    echo "set -g status-utf8 on" >> "$conf_file"
    echo "" >> "$conf_file"
    echo "# vim keybindings" >> "$conf_file"
    echo "setw -g mode-keys vi" >> "$conf_file"
    echo "bind-key -T copy-mode-vi v send-keys -X begin-selection" >> "$conf_file"
    echo "bind-key -T copy-mode-vi y send-keys -X copy-selection" >> "$conf_file"
    echo "" >> "$conf_file"
    echo "# Shift + Arrow to scroll" >> "$conf_file"
    echo "ind-key -n S-Up send-keys -X scroll-up" >> "$conf_file"
    echo "ind-key -n S-Down send-keys -X scroll-down" >> "$conf_file"
    echo "" >> "$conf_file"
    echo "# Others" >> "$conf_file"
    echo "set -g mouse on" >> "$conf_file"
    echo "set -g set-clipboard on" >> "$conf_file"
    echo "set -g history-limit 5000" >> "$conf_file"
fi

# 設定を反映
tmux source-file ~/.tmux.conf

# EDITOR環境変数の設定
# 
if ! grep -q 'export EDITOR=vim' "$HOME/.bashrc"; then
    echo 'export EDITOR=vim' >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
fi

echo "Setup completed successfully!"

