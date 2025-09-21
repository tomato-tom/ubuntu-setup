#!/bin/bash
# script/sync_dotfiles.sh
# 設定ファイルを同期

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"
LOGGER="$PROJECT_ROOT/lib/logger.sh"
[ -f "$LOGGER" ] && source $LOGGER $0 || exit 1

# souce:targetのペア
file_pairs=(
    "$PROJECT_ROOT/dotfiles/bashrc:$HOME/.bashrc"
    "$PROJECT_ROOT/dotfiles/fcitx5-profile:$HOME/.config/fcitx5/profile"
    "$PROJECT_ROOT/dotfiles/fcitx5.service:$HOME/.config/systemd/user/fcitx5.service"
    "$PROJECT_ROOT/dotfiles/init.lua:$HOME/.config/nvim/init.lua"
    "$PROJECT_ROOT/dotfiles/screenrc:$HOME/.screenrc"
    "$PROJECT_ROOT/dotfiles/tmux.conf:$HOME/.tmux.conf"
)

sync() {
    local source=$1
    local target=$2
    local updatefile

    log info "sync: $source ↔ $target"

    if output="$(rsync -aui "$source" "$target" 2>&1)"; then
        [ -n "$output" ] && {
            update_file="$(echo $output | awk '{print $2}')"
            echo "exit code: $?"
            log info "update: $update_file"
            echo "exit code: $?"
        }
    fi

    if output="$(rsync -aui "$target" "$source" 2>&1)"; then
        [ -n "$output" ] && {
            update_file="$(echo "$output" | awk '{print $2}')"
            log info "update: $update_file"
        }
    fi

    return 0
}

for pair in "${file_pairs[@]}"; do
    IFS=':' read -r source target <<< "$pair"
    sync "$source" "$target"
done

