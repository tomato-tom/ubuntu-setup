#!/bin/bash

set -e

# tmuxのインストール
sudo apt-get update
sudo apt-get install -y tmux

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
echo "# Custom settings" >> "$HOME/.tmux.conf.local"
echo "set -g utf8 on" >> "$HOME/.tmux.conf.local"
echo "set -g status-utf8 on" >> "$HOME/.tmux.conf.local"
echo "setw -g mode-keys vi" >> "$HOME/.tmux.conf.local"
echo "bind-key -T copy-mode-vi v send-keys -X begin-selection" >> "$HOME/.tmux.conf.local"
echo "bind-key -T copy-mode-vi y send-keys -X copy-selection" >> "$HOME/.tmux.conf.local"
echo "set -g mouse on" >> "$HOME/.tmux.conf.local"
echo "set -g history-limit 5000" >> "$HOME/.tmux.conf.local"

# 設定を反映
tmux source-file ~/.tmux.conf

# EDITOR環境変数の設定
if ! grep -q 'export EDITOR=vim' "$HOME/.bashrc"; then
    echo 'export EDITOR=vim' >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
fi

echo "Setup completed successfully!"

# ~ 動作確認 ~~~
# 絵文字が表示される
# viモードで操作できる
# マウススクロールが可能
# ステータスバーにカスタム設定が反映されている

