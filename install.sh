#!/bin/bash
set -euo pipefail

# Install python-nautilus
if type "pacman" >/dev/null 2>&1; then
    # check if already install, else install
    pacman -Qi python-nautilus &>/dev/null
    if [ "$?" -eq 1 ]; then
        echo "Installing python-nautilus..."
        sudo pacman -S --noconfirm python-nautilus
    fi
elif type "apt-get" >/dev/null 2>&1; then
    # Find Ubuntu python-nautilus package
    package_name="python3-nautilus"
    found_package=$(apt-cache search --names-only $package_name)
    if [ -z "$found_package" ]; then
        package_name="python3-nautilus"
    fi

    # Check if the package needs to be installed and install it
    installed=$(apt list --installed $package_name -qq 2>/dev/null)
    if [ -z "$installed" ]; then
        echo "Installing python-nautilus..."
        sudo apt-get install -y $package_name
    fi
elif type "dnf" >/dev/null 2>&1; then
    installed=$(dnf list --installed nautilus-python 2>/dev/null)
    if [ -z "$installed" ]; then
        echo "Installing python-nautilus..."
        sudo dnf install -y nautilus-python
    fi
else
    echo "Failed to find python-nautilus, make sure to install it manually."
fi

# Install scripts
NAUTILUS_PYTHON_SCRIPTS="$HOME"/.local/share/nautilus-python/extensions
mkdir -p "$NAUTILUS_PYTHON_SCRIPTS"
if [ -z "${1-}" ]; then
    cp "$(dirname "$(realpath "$0")")"/src/* "$NAUTILUS_PYTHON_SCRIPTS"/
else
    echo "TODO: Install specific submenu"
fi

# Restart nautilus
echo "Restarting nautilus..."
nautilus -q || :

echo "Installed sucessfully."
