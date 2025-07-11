#!/bin/bash -e

# The script is essentially setting up Fcitx5 input method for Ubuntu 24.04.
# Installing the necessary packages, configuring auto-start,
# handling GNOME-specific environment variables, and creating a configuration file for Fcitx5.

# Install fcitx5 and necessary packages
sudo apt-get update
sudo apt-get install -y fcitx5 fcitx5-mozc fcitx5-config-qt

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
# mkdir -p "$HOME/.config/fcitx5" 
# This directory is automatically created during the fcitx5 installation

CONFIG_DIR="$HOME/.config/fcitx5"
CONFIG_FILE="$CONFIG_DIR/profile"

# Wait for the fcitx5 configuration file to be created
count=0
while [ ! -f "$CONFIG_FILE" ]; do
    if [ $count -gt 30 ]; then
        echo "Timeout: Fcitx5 configuration file not created after 30 seconds."
        exit 1
    fi
    echo "Waiting for fcitx5 configuration file to be created..."
    sleep 1
    count=$((count + 1))
done

echo "Creating new configuration..."

cat <<EOF > $CONFIG_FILE
[Groups/0]
# Group Name
Name=Default
# Layout
Default Layout=us
# Default Input Method
DefaultIM=mozc

[Groups/0/Items/0]
# Name
Name=keyboard-us
# Layout
Layout=

[Groups/0/Items/1]
# Name
Name=mozc
# Layout
Layout=

[GroupOrder]
0=Default
EOF

echo "Restart Fcitx5..."
fcitx5 -r &

