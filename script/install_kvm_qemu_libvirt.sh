#!/bin/bash -e

# Minimum installation to build a KVM virtual environment.
sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients
sudo apt-get install -y bridge-utils virtinst libosinfo-bin

# Add current user to libvirt group
sudo usermod -a -G libvirt $(whoami)
sudo systemctl restart libvirtd

echo "Please reboot to apply libvirt group to current user"
echo "Or you can apply it temporarily with the command: newgrp libvirt"

