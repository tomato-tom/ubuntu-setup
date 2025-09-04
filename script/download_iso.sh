#!/bin/bash
# ISO download and verification script
# - GPG key verification
# - Local ISO checksum validation (if exists)
# - Download from mirror
# - Checksum verification

set -euo pipefail

LOGGER="$(dirname "${BASH_SOURCE[0]}")/../lib/logger.sh"
[ -f "$LOGGER" ] && source "$LOGGER" || exit 1

# Configuration
MIRROR_URL="https://jp.mirror.coganng.com/ubuntu-cdimage/jammy"
ISO_NAME="ubuntu-22.04.5-live-server-amd64.iso"
SHA_FILE="SHA256SUMS"
GPG_FILE="SHA256SUMS.gpg"
LOCAL_ISO_DIR="/mnt/iso"
LOCAL_ISO_PATH="${LOCAL_ISO_DIR}/${ISO_NAME}"
WORK_DIR="/tmp/ubuntu-iso-work-$$"  # プロセスIDを追加してユニークに

# Required tools check
command -v wget >/dev/null 2>&1 || { log error "wget is required"; exit 1; }
command -v gpg >/dev/null 2>&1 || { log error "GPG is required"; exit 1; }
command -v sha256sum >/dev/null 2>&1 || { log error "sha256sum is required"; exit 1; }

# Cleanup function
cleanup() {
    log info "Cleaning up working directory..."
    rm -rf "$WORK_DIR"
}

# Set trap for cleanup on exit
trap cleanup EXIT

# Create local ISO directory and working directory
mkdir -p "$LOCAL_ISO_DIR"
mkdir -p "$WORK_DIR"

cd "$WORK_DIR"

# Download SHA256SUMS and GPG signature
log info "Downloading SHA256SUMS..."
wget -nc "${MIRROR_URL}/${SHA_FILE}" -O "${SHA_FILE}"

log info "Downloading GPG signature..."
wget -nc "${MIRROR_URL}/${GPG_FILE}" -O "${GPG_FILE}"

# Get Ubuntu public key (first time only)
if ! gpg --list-keys "Ubuntu CD Image Automatic Signing Key" >/dev/null 2>&1; then
    log info "Importing Ubuntu GPG key..."
    gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys "843938DF228D22F7B3742BC0D94AA3F0EFE21092"
fi

# GPG signature verification
log info "Verifying GPG signature..."
if gpg --verify "${GPG_FILE}" "${SHA_FILE}"; then
    log info "✅ Signature is valid (official Ubuntu build)"
else
    log error "❌ Invalid signature detected!"
    exit 1
fi

# Function to verify checksum
verify_iso_checksum() {
    local iso_path="$1"
    local sha_path="${WORK_DIR}/${SHA_FILE}"
    local iso_dir=$(dirname "$iso_path")
    local iso_filename=$(basename "$iso_path")
    
    log info "Verifying checksum for: $iso_path"
    
    # ISOディレクトリに移動してチェックサム検証
    (
        cd "$iso_dir"
        if sha256sum -c --ignore-missing < "$sha_path" 2>/dev/null | grep -q "$iso_filename"; then
            exit 0
        else
            exit 1
        fi
    )
}

# Check if local ISO exists and verify its checksum
if [ -f "$LOCAL_ISO_PATH" ]; then
    log info "Local ISO found: $LOCAL_ISO_PATH"
    
    if verify_iso_checksum "$LOCAL_ISO_PATH"; then
        log info "✅ Local ISO is valid, no download needed"
        exit 0
    else
        log warn "Local ISO checksum failed, removing and downloading fresh copy"
        rm -f "$LOCAL_ISO_PATH"
    fi
else
    log info "Local ISO not found: $LOCAL_ISO_PATH"
fi

# Download ISO from mirror
log info "Downloading ISO from mirror..."
cd "$WORK_DIR"
wget "${MIRROR_URL}/${ISO_NAME}" -O "${ISO_NAME}"

# Final checksum verification
log info "Performing final checksum verification..."
if verify_iso_checksum "${WORK_DIR}/${ISO_NAME}"; then
    log info "✅ ISO downloaded and verified successfully"
    mv "${ISO_NAME}" "$LOCAL_ISO_PATH"
    log info "ISO moved to: $LOCAL_ISO_PATH"
else
    log error "❌ Downloaded ISO checksum verification failed"
    exit 1
fi

log info "All verifications completed successfully"
