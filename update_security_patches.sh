#!/bin/bash

# Strict mode
set -euo pipefail

# Check if the script is run with administrative privileges
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run with administrative privileges." 1>&2
    exit 1
fi

# Function to detect the Linux distribution
get_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/redhat-release ]; then
        echo "rhel"
    else
        echo "unknown"
    fi
}

# Function to update only security patches for different distributions
update_security_patches() {
    distro=$(get_distro)
    case "$distro" in
        debian|ubuntu)
            apt update && apt upgrade --only-security -y
            ;;
        centos|rhel|fedora)
            yum check-update && yum update --security -y
            ;;
        opensuse)
            zypper refresh && zypper patch --category security -y
            ;;
        arch)
            pacman -Syu --noconfirm
            ;;
        *)
            echo "Unknown distribution. Cannot update security patches." >&2
            exit 1
            ;;
    esac
}

# Call the function to update only security patches
update_security_patches

echo "Security patches update completed."
