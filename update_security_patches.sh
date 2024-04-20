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
            # Refresh the list of available packages
            apt-get update
            # Get the list of upgradable packages
            upgradable=$(apt list --upgradable 2>/dev/null)
            # Filter the list to include only security updates
            security_updates=$(echo "$upgradable" | awk '/\[upgradable from:.*security\]/{print $1}')
            echo "$security_updates"
            # exit 0
            # Update only security patches
            if [ -n "$security_updates" ]; then
                apt-get install $security_updates -y
            else
                echo "No security updates available."
            fi
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
