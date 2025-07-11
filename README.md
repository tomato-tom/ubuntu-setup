# Ubuntu初期設定

主にUbuntuデスクトップのインストール後の初期設定スクリプト


## ディレクトリ構成

`setup.sh`で他のスクリプトを順次実行
```
.
├── lib
│   └── logger.sh
├── logs
│   └── script.log
├── README.md
└── script
    ├── fcitx5setup.sh
    ├── install_neovim.sh
    ├── keymap.sh
    ├── obsidian_update.sh
    ├── package_install.sh
    ├── package_list.txt
    ├── setup.sh
    ├── setup_tmux.sh
    └── update_grub.sh
```

## 各スクリプトの説明

### setup.sh
以下のいくつかのスクリプトを実行

### keymap.sh
CapsLockキーをCtrlに変更

### package_install.sh
初期設定後にとりあえず入れとくパッケージを`package_list.txt`に記入して、
順次インストール

### install_neovim.sh
neovimをインストールして、デフォルトエディタに設定

### obsidian_update.sh
obsidianのインストールと更新

### setup_tmux.sh
tmuxのセットアップ

### fcitx5setup.sh
fcitx5による日本語入力環境

### update_grub.sh
grubの設定、マルチブート環境で必要になるかも


## Todo

`logger.sh`を使用してログ書き込み

- fcitx5setup.sh
- install_neovim.sh
- keymap.sh
- obsidian_update.sh
- package_install.sh ✅
- setup.sh
- setup_tmux.sh
- update_grub.sh

gnomeデスクトップ環境のスクリプトによる設定
- ダークテーマ
- ショートカットキー

PXEブート、Autoinstallによる自動化
> https://canonical-subiquity.readthedocs-hosted.com/en/latest/tutorial/index.html
> https://gihyo.jp/admin/serial/01/ubuntu-recipe/0787

