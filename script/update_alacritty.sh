#!/bin/bash

# 設定変数
ALACRITTY_DIR="$HOME/.local/src/alacritty"
INSTALL_PREFIX="/usr/local"
REPO_URL="https://github.com/alacritty/alacritty.git"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"
LOGGER="$PROJECT_ROOT/lib/logger.sh"
[ -f "$LOGGER" ] && source $LOGGER $0 || exit 1

# 依存関係のインストール (Ubuntu/Debian)
install_dependencies() {
    log info "Updating package list and installing dependencies..."
    sudo apt update
    # Wayland + Nvidia の場合は libegl1-mesa-dev も必要になる場合があります
    sudo apt install -y \
        cmake \
        g++ \
        pkg-config \
        libfontconfig1-dev \
        libxcb-xfixes0-dev \
        libxkbcommon-dev \
        python3 \
        git \
        curl \
        gzip \
        scdoc \
        libegl1-mesa-dev &&
        log info "Dependencies installed."
}

# Rust コンパイラのインストール (rustup)
install_rust() {
    if ! command -v cargo &> /dev/null; then
        log info "Rust not found. Installing rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        # 環境変数の読み込み
        source "$HOME/.cargo/env"
        log info "Rust installed."
    else
        log info "Rust already installed. Updating toolchain..."
        source "$HOME/.cargo/env"
        rustup update stable
        rustup override set stable
    fi
}

# ソースコードのクローンまたは更新
get_source() {
    if [ -d "$ALACRITTY_DIR" ]; then
        log info "Updating existing repository..."
        cd "$ALACRITTY_DIR"
        git pull
    else
        log info "Cloning repository..."
        mkdir -p "$(dirname "$ALACRITTY_DIR")"
        git clone --depth 1 "$REPO_URL" "$ALACRITTY_DIR"
        cd "$ALACRITTY_DIR"
    fi
    log info "Source code ready."
}

# ビルド
build_alacritty() {
    log info "Building Alacritty (this may take a while)..."
    source "$HOME/.cargo/env"
    cargo build --release
    log info "Build completed."
    beep -r 3
}

# システムへのインストール
install_artifacts() {
    log info "Installing binaries and assets..."
    
    # バイナリ
    sudo cp target/release/alacritty "$INSTALL_PREFIX/bin/"
    
    # Terminfo
    sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
    
    # Desktop Entry
    sudo cp target/release/alacritty "$INSTALL_PREFIX/bin/"
    sudo cp extra/logo/alacritty-term.svg "/usr/share/pixmaps/Alacritty.svg"
    sudo desktop-file-install extra/linux/Alacritty.desktop
    sudo update-desktop-database
    
    # Manual Page
    sudo mkdir -p "$INSTALL_PREFIX/share/man/man1"
    sudo mkdir -p "$INSTALL_PREFIX/share/man/man5"
    scdoc < extra/man/alacritty.1.scd | gzip -c | sudo tee "$INSTALL_PREFIX/share/man/man1/alacritty.1.gz" > /dev/null
    scdoc < extra/man/alacritty-msg.1.scd | gzip -c | sudo tee "$INSTALL_PREFIX/share/man/man1/alacritty-msg.1.gz" > /dev/null
    scdoc < extra/man/alacritty.5.scd | gzip -c | sudo tee "$INSTALL_PREFIX/share/man/man5/alacritty.5.gz" > /dev/null
    scdoc < extra/man/alacritty-bindings.5.scd | gzip -c | sudo tee "$INSTALL_PREFIX/share/man/man5/alacritty-bindings.5.gz" > /dev/null
    
    # Shell Completions (Bash)
    mkdir -p ~/.bash_completion
    cp extra/completions/alacritty.bash ~/.bash_completion/alacritty
    if ! grep -q "source ~/.bash_completion/alacritty" ~/.bashrc; then
        echo "source ~/.bash_completion/alacritty" >> ~/.bashrc
    fi

    log info "Artifacts installed."
}

# 設定ファイルの準備
setup_config() {
    log info "Preparing configuration directory..."
    # Alacritty は設定ファイルを自動作成しないため、ディレクトリのみ作成します
    CONFIG_DIR="$HOME/.config/alacritty"
    mkdir -p "$CONFIG_DIR"
    
    if [ ! -f "$CONFIG_DIR/alacritty.toml" ]; then
        # 空の設定ファイルを作成（デフォルト設定で使用可能）
        touch "$CONFIG_DIR/alacritty.toml"
        log warn "Config file created at $CONFIG_DIR/alacritty.toml (empty defaults)."
    else
        log info "Config file already exists."
    fi
    log info "Configuration setup complete."
}

# メイン処理
main() {
    echo "========================================="
    echo "  Alacritty Build & Setup Script (Ubuntu)"
    echo "========================================="
    
    install_dependencies
    install_rust
    get_source
    build_alacritty
    install_artifacts
    setup_config
    
    echo ""
    log info "Alacritty installation/update complete!"
    log info "You can now launch Alacritty from your application menu or by running 'alacritty'."
    log info "Config file location: $HOME/.config/alacritty/alacritty.toml"
}

main
