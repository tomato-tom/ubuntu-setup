#!/bin/bash -e
# script/fcitx5setup.sh
# Setting up Fcitx5 input method for Archlinux

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"
LOGGER="$PROJECT_ROOT/lib/logger.sh"
[ -f "$LOGGER" ] && source "$LOGGER" "$0" || exit 1

# Install fcitx5 and necessary packages
if ! command -v fcitx5 >/dev/null 2>&1; then
    log info "Installing fcitx5 packages..."
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm fcitx5 fcitx5-mozc fcitx5-configtool
fi

# Set environment variables for fcitx5
log info "Setting up fcitx5 environment variables..."
ENV_FILE="$HOME/.config/environment.d/fcitx5.conf"
mkdir -p "$(dirname "$ENV_FILE")"

if [ ! -f "$ENV_FILE" ] || ! grep -q "GTK_IM_MODULE=fcitx" "$ENV_FILE"; then
    cat > "$ENV_FILE" << EOF
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
EOF
    log info "Environment variables configured in $ENV_FILE"
else
    log info "Environment variables already configured"
fi

update_config() {
    local source_file="$1"
    local config_file="$2"
    local config_dir="$(dirname "$config_file")"
    
    mkdir -p "$config_dir"

    log info "Update: $config_file"
    if [ -f "$source_file" ] && [ -f "$config_file" ]; then
        if ! diff "$source_file" "$config_file" >/dev/null 2>&1; then
            cp -f "$source_file" "$config_file"
            log info "Configuration updated"
        else
            log info "Configuration already up to date"
        fi
    elif [ -f "$source_file" ]; then
        cp "$source_file" "$config_file"
        log info "Configuration created"
    else
        log error "File not found: $source_file"
        return 1
    fi
    return 0
}

# Update the fcitx5 configuration file
fcitx5_source="$PROJECT_ROOT/dotfiles/fcitx5-profile"
fcitx5_config_dir="$HOME/.config/fcitx5"
fcitx5_config_file="$fcitx5_config_dir/profile"

# Wait for configuration file to be created
max_wait=5
elapsed=0
while [ $elapsed -le $max_wait ]; do
    [ -f "$fcitx5_config_file" ] && break
    log info "Waiting for fcitx5 configuration file to be created... ($((elapsed+1))/$max_wait)"
    ((elapsed++))
    sleep 1
done

if [ ! -f "$fcitx5_config_file" ]; then
    log warn "fcitx5 configuration file not found after waiting, creating manually..."
    mkdir -p "$fcitx5_config_dir"
    touch "$fcitx5_config_file"
fi

update_config "$fcitx5_source" "$fcitx5_config_file"

# Update the fcitx5 service file
service_source="$PROJECT_ROOT/dotfiles/fcitx5.service"
service_config_dir="$HOME/.config/systemd/user"
service_config_file="$service_config_dir/fcitx5.service"

update_config "$service_source" "$service_config_file"

# Reload systemd user configuration
log info "Setting up Fcitx5 service..."
systemctl --user daemon-reload
systemctl --user --now enable fcitx5.service
systemctl --user restart fcitx5.service

log info "Fcitx5 setup completed successfully"
log info "Please log out and log back in for changes to take effect"
