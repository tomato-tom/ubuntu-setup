#!/bin/bash -e
# script/fcitx5setup.sh
# The script is essentially setting up Fcitx5 input method for Ubuntu 24.04.
# Installing the necessary packages, configuring auto-start,
# handling GNOME-specific environment variables, and creating a configuration file for Fcitx5.

LOGGER="$(dirname "${BASH_SOURCE[0]}")/../lib/logger.sh"
[ -f "$LOGGER" ] && source $LOGGER || exit 1

# Install fcitx5 and necessary packages
if command -v fcitx5 >/dev/null; then
    sudo apt-get update
    sudo apt-get install -y fcitx5 fcitx5-mozc fcitx5-config-qt
fi

# Set fcitx5 as the input method
sudo im-config -n fcitx5

# Add auto-start setting for fcitx5 to ~/.profile
if ! grep -q "fcitx5" "$HOME/.profile"; then
    echo "fcitx5 > /dev/null 2>&1 &" >> "$HOME/.profile"
fi

source "$HOME/.profile"

# GNOME specific environment variables
# https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland#GNOME
if ! grep -q "# fcitx5" "$HOME/.bashrc"; then
    echo >> $HOME/.bashrc
    cat << EOF >> $HOME/.bashrc
# fcitx5
export XMODIFIERS=@im=fcitx
export QT_IM_MODULE=fcitx
export GTK_IM_MODULE=fcitx
EOF
fi

source "$HOME/.bashrc"

sleep 1

# Create the fcitx5 configuration file
CONFIG_DIR="$HOME/.config/fcitx5"
CONFIG_FILE="$CONFIG_DIR/profile"

# Wait for the fcitx5 configuration file to be created
count=0
while [ ! -f "$CONFIG_FILE" ]; do
    if [ $count -gt 5 ]; then
        log warn "Timeout: Fcitx5 configuration file not created after 5 seconds."
        mkdir -p $CONFIG_DIR
    fi
    log info "Waiting for fcitx5 configuration file to be created..."
    sleep 1
    count=$((count + 1))
done

log info "Creating new configuration..."

src="$(dirname "${BASH_SOURCE[0]}")/../dotfiles/fcitx5-profile"
[ -f "$src" ] && cp -f $src $CONFIG_FILE || {
    log error "file not found: $src"
    exit 1
}

log info "Restart Fcitx5..."
fcitx5 -r &

