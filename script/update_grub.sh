#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"
LOGGER="$PROJECT_ROOT/lib/logger.sh"
[ -f "$LOGGER" ] && source $LOGGER $0 || exit 1

log info "Check current UEFI boot entry"
efibootmgr
echo

log info "Crate backup"
sudo cp /etc/default/grub /etc/default/grub.bak

# Next time the same OS startup as now
sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub
sudo sed -i '/^GRUB_DEFAULT=/aGRUB_SAVEDEFAULT=true' /etc/default/grub

# Set grub menu timeout to 10 seconds
sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=10/' /etc/default/grub
sudo sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub

# Apply settings
sudo update-grub

log info "Updated GRUB settings. Please reboot now."

