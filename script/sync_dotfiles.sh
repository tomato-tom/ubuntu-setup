#!/bin/bash
# script/sync_dotfiles.sh
# 設定ファイルを同期
# 各ファイルの１行目にターゲットパス書いとく

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"
LOGGER="$PROJECT_ROOT/lib/logger.sh"
[ -f "$LOGGER" ] && source $LOGGER $0 || exit 1

sync() {
    local src=$1
    local dst=$2
    local updatefile

    log debug "sync: $src ↔ $dst"

    if output="$(rsync -aui "$src" "$dst" 2>&1)"; then
        [ -n "$output" ] && {
            update_file="$(echo $output | awk '{print $2}')"
            log info "update: $update_file"
        }
    fi

    if output="$(rsync -aui "$dst" "$src" 2>&1)"; then
        [ -n "$output" ] && {
            update_file="$(echo "$output" | awk '{print $2}')"
            log info "update: $update_file"
        }
    fi

    return 0
}

for src in "$PROJECT_ROOT"/dotfiles/*; do
    [ ! -f "$src" ] && continue
    path="$(head -n 1 $src | cut -d' ' -f2)"
    dst="${path/#\~/$HOME}"
    [ -z "$dst" ] && continue
    mkdir -p "$(dirname $dst)"
    sync "$src" "$dst"
done
