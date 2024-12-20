#!/bin/bash

# Map Caps Lock key to Control
# Tested on:
# Ubuntu 22.04~24.04
# Apple MacBook Air 6.1
# Apple Mac mini 6.1

# Check if the script is being run with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Display connected keyboard devices
echo "Connected keyboard devices:"
keyboard_devices=$(lsusb | grep "Keyboard")

# Check the number of keyboard devices found
num_devices=$(echo "$keyboard_devices" | wc -l)

if [ "$num_devices" -eq 0 ]; then
    echo "No keyboard devices found."
    exit 1
elif [ "$num_devices" -gt 1 ]; then
    echo "Multiple keyboard devices found."
    echo "$keyboard_devices"
    exit 1
fi

# Extract vendor ID and product ID
vendor_id=$(echo "$keyboard_devices" | awk '{print $6}' | cut -d':' -f1 | tr '[:lower:]' '[:upper:]')
product_id=$(echo "$keyboard_devices" | awk '{print $6}' | cut -d':' -f2 | tr '[:lower:]' '[:upper:]')

# Extract device name
device_name=$(echo "$keyboard_devices" | awk '{for (i=7; i<=NF; i++) printf $i " "; print ""}')

echo "vendorID: $vendor_id"
echo "productID: $product_id"
echo "Device name: $device_name"

# Find an available hwdb file number
for i in {90..99}; do
    hwdb_file="/etc/udev/hwdb.d/${i}-custom-keyboard.hwdb"
    if [ ! -f "$hwdb_file" ]; then
        echo "Creating configuration file: $hwdb_file"
        cat << EOF > "$hwdb_file"
evdev:input:b*v${vendor_id}p${product_id}*
  KEYBOARD_KEY_70039=leftctrl
EOF
        break
    fi
done

# Apply the new configuration
systemd-hwdb update
udevadm trigger

echo "Applying configuration..."

# ---- The following commands are not tested ---------------
# Wait and check for the configuration to take effect
max_wait_time=10
wait_time=0
while [ $wait_time -lt $max_wait_time ]; do
    # Check the keyboard configuration
    result=$(udevadm info /dev/input/by-path/*-usb-*-kbd | grep KEYBOARD_KEY)

    if [ ! -z "$result" ]; then
        echo "Configuration applied: $result"
        break
    fi

    # If configuration is not applied, wait for 1 second and retry
    sleep 1
    wait_time=$((wait_time + 1))
done

# If the configuration was not applied within 10 seconds, show a timeout message
if [ $wait_time -ge $max_wait_time ]; then
    echo "Error: Configuration not applied within $max_wait_time seconds."
fi

