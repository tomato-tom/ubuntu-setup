#!/bin/bash

# =============================================================================
#
# This script does the following:
# 
#   * It checks the currently installed version of Obsidian.
#   * It compares it with the latest version available on GitHub.
#   * If the installed version is outdated, it downloads the latest AppImage, 
#     replaces the old version, and sets up a symbolic link for easy execution.
#
# ----------------------------------------------------------------------------

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"
LOGGER="$PROJECT_ROOT/lib/logger.sh"
[ -f "$LOGGER" ] && source $LOGGER $0 || exit 1

# Directory where Obsidian's AppImage is installed
INSTALL_DIR="$HOME/.local/share/obsidian"
mkdir -p "$INSTALL_DIR"

# URL for the JSON file with release information
JSON_URL="https://raw.githubusercontent.com/obsidianmd/obsidian-releases/master/desktop-releases.json"

# Local version of Obsidian installed (filename)
LOCAL_APPIMAGE=$(ls $INSTALL_DIR/Obsidian*.AppImage 2>/dev/null)
if [ -z "$LOCAL_APPIMAGE" ]; then
    LOCAL_VERSION=""
else
    LOCAL_VERSION=$(basename "$LOCAL_APPIMAGE" | sed -E 's/Obsidian-([0-9]+\.[0-9]+\.[0-9]+)\.AppImage/\1/')
fi

# Fetch the latest version information from GitHub repository
LATEST_VERSION=$(curl -s "$JSON_URL" | jq -r '.latestVersion')
DOWNLOAD_URL=$(curl -s "$JSON_URL" | jq -r '.downloadUrl')

# Check if the local version is the same as the latest version
if [ "$LOCAL_VERSION" == "" ]; then
    log info "Installing for the first time"
    sudo apt update
    sudo apt install libfuse2t64 -y
elif [ "$LOCAL_VERSION" == "$LATEST_VERSION" ]; then
    log info "The latest version ($LATEST_VERSION) is already installed."
    exit 0
else
    log info "Deleting old AppImage..."
    rm -f "$INSTALL_DIR/$(basename "$LOCAL_APPIMAGE")"
fi

# Convert the download URL to the latest AppImage URL
APPIMAGE_URL=$(log info "$DOWNLOAD_URL" | sed -E 's/obsidian-([0-9]+\.[0-9]+\.[0-9]+)\.asar\.gz/Obsidian-\1.AppImage/')

# Filename for the latest AppImage
APPIMAGE=$(basename "$APPIMAGE_URL")


# Download the latest AppImage
log info "Downloading the latest version of Obsidian..."
wget -q --show-progress "$APPIMAGE_URL" -O "$INSTALL_DIR/$APPIMAGE"

# If download was successful
if [ $? -eq 0 ]; then
    # Make the AppImage executable
    chmod 744 "$INSTALL_DIR/$APPIMAGE"
    
    # Create a symbolic link
    ln -sf "$INSTALL_DIR/$APPIMAGE" "$HOME/.local/bin/obsidian"
    
    log info "Obsidian has been updated successfully!"
    log info "To run: obsidian --no-sandbox"
else
    log error "Download failed."
    exit 1
fi

