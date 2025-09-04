#!/bin/bash
# lib/logger.sh
#
# Usage example:
#   source ../lib/logger.sh $0
#   log info "start myscript"
#   log warn "something wrong"
#   log error "file not found: file"
#
# Directory structure:
#   script/*.sh
#   lib/logger.sh      # This script
#   logs/script.log

# Log file configuration
SOURCE_SCRIPT=$0
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"
LOG_DIR="$PROJECT_ROOT/logs"
LOG_FILE="$LOG_DIR/script.log"
LOG_MAX_SIZE=$((1024*1024))  # 1MB (in bytes)
LOG_MAX_FILES=3              # Maximum number of log files to keep

echo "BASH_SOURCE[0]: ${BASH_SOURCE[0]}"
echo "LIB_DIR: $LIB_DIR"
echo "LOG_DIR: $LOG_DIR"
echo "LOG_FILE: $LOG_FILE"

mkdir -p "$LOG_DIR"

# Color coding based on log level
COLOR_INFO="\033[32m"    # Green
COLOR_WARN="\033[33m"    # Yellow
COLOR_ERROR="\033[31m"   # Red
COLOR_RESET="\033[0m"

# Log rotation function
rotate_log() {
    # Check if log file exists and exceeds size limit
    [ -f "$LOG_FILE" ] || return 0
    [ $(stat -c%s "$LOG_FILE") -le $LOG_MAX_SIZE ] && return 0

    # Remove oldest log file if max count reached
    [ -f "${LOG_FILE}.${LOG_MAX_FILES}" ] && rm -f "${LOG_FILE}.${LOG_MAX_FILES}"

    # Rename existing log files in reverse order
    for ((i=LOG_MAX_FILES-1; i>=1; i--)); do
        [ -f "${LOG_FILE}.${i}" ] && mv -f "${LOG_FILE}.${i}" "${LOG_FILE}.$((i+1))"
    done

    # Rotate current log file
    mv -f "$LOG_FILE" "${LOG_FILE}.1"
}

# Log writing function
log() {
    local level=$1
    local message=$2
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    rotate_log
    
    # Select color based on log level
    case $level in
        info) local color=$COLOR_INFO ;;
        warn) local color=$COLOR_WARN ;;
        error) local color=$COLOR_ERROR ;;
        *) local color=$COLOR_RESET ;;
    esac
    
    # Output to both console and log file
    echo -e "${color}[${level^^}] ${message}${COLOR_RESET}"
    echo "[${timestamp}] [${level^^}] [${SOURCE_SCRIPT}] ${message}" >> "$LOG_FILE"
}

