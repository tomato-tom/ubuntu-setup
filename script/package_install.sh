#!/bin/bash

# Directory structure:
# script/package_install.sh      # This script
# lib/logger.sh
# logs/script.log

# Package list file
PKG_FILE="$(dirname "$0")/package_list.txt"

# Check dependencies
check_dependencies() {
    if ! command -v apt &> /dev/null; then
        log error "Command not found: apt"
        exit 1
    fi
}

# Parse package list file
parse_package_list() {
    local section=""
    declare -A packages

    while IFS= read -r line; do
        # Detect section headers
        if [[ "$line" =~ ^#\ [^#]+ ]]; then
            section="${line#*# }"
            continue
        fi
        
        # Skip comments and empty lines
        [[ "$line" =~ ^#|^$ ]] && continue
        
        # Extract package name (first word before whitespace)
        pkg=$(echo "$line" | awk '{print $1}')
        packages["$section"]+="$pkg "
    done < "$PKG_FILE"

    declare -p packages | sed "s/declare -A/declare -gA/"
}

main() {
    source ../lib/logger.sh $0
    check_dependencies
    
    log info "Updating package lists..."
    sudo apt update -q
    
    eval "$(parse_package_list)"
    
    for section in "${!packages[@]}"; do
        if [ -z "${packages[$section]}" ]; then
            continue
        fi
        
        log info "=== Installing ${section} ==="
        log info "Packages: ${packages[$section]}"
        
        # Actual installation
        sudo apt install -y --no-install-recommends ${packages[$section]}
        
        if [ $? -eq 0 ]; then
            log info "Successfully installed ${section}"
        else
            log error "Failed to install ${section}"
        fi
    done
    
    log info "Cleaning up unused packages..."
    sudo apt autoremove -y
}

main

