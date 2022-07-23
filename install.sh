#!/bin/sh
set -eu

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

if ! type nautilus >/dev/null 2>&1; then
    printf "${RED}Nautilus not installed on system${NC}"
    exit 1
fi

printf_install() {
    printf "${GREEN}Download python-nautilus${NC}"
}

# Install python-nautilus
if type pacman >/dev/null 2>&1; then
    # check if already install, else install
    # installed=$(pacman -Qi python-nautilus 2>/dev/null || :)
    # if [ -z "$installed" ]; then
    #     printf_install
    #     sudo pacman -S --noconfirm python-nautilus
    # fi
    printf_install
    sudo pacman -S --noconfirm --needed python-nautilus
elif type apt-get >/dev/null 2>&1; then
    # Find Ubuntu python-nautilus package
    # package_name="python3-nautilus"
    # found_package=$(apt-cache search --names-only $package_name)
    # if [ -z "$found_package" ]; then
    #     package_name="python3-nautilus"
    # fi

    # # Check if the package needs to be installed and install it
    # installed=$(apt list --installed $package_name -qq 2>/dev/null)
    # if [ -z "$installed" ]; then
    #     printf_install
    #     sudo apt-get install -y $package_name
    # fi
    printf_install
    sudo apt-get install -y python3-nautilus
elif type dnf >/dev/null 2>&1; then
    # installed=$(dnf list --installed nautilus-python 2>/dev/null)
    # if [ -z "$installed" ]; then
    #     printf_install
    #     sudo dnf install -y nautilus-python
    # fi
    printf_install
    sudo dnf install -y nautilus-python
else
    printf "${RED}Pkg manager not supported, failed to install python-nautilus, make sure to install it manually${NC}"
fi

# Install scripts
INSTALL_DIR="$(realpath "${1:-$HOME/.nautilus-python-submenus}")"
if [ ! -d "$INSTALL_DIR"/src ]; then
    printf "${GREEN}Downloading nautilus-python-submenus to %s${NC}\n" "$INSTALL_DIR"
    git clone https://github.com/haoadoreorange/nautilus-python-submenus "$INSTALL_DIR"
else
    printf "${GREEN}nautilus-python-submenus already downloaded at %s, pulling newest commit${NC}\n" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    git pull
fi

NAUTILUS_PYTHON_SCRIPTS="$HOME"/.local/share/nautilus-python/extensions
mkdir -p "$NAUTILUS_PYTHON_SCRIPTS"
for file in "$INSTALL_DIR"/src/*; do
    if [ -f "$file" ]; then
        if [ ! -f "$NAUTILUS_PYTHON_SCRIPTS/$(basename "$file")" ]; then
            printf "${GREEN}Softlinking nautilus submenu '%s' to %s${NC}\n" "$(basename "$file")" "$NAUTILUS_PYTHON_SCRIPTS"
            chmod +x "$file"
            ln -s "$file" "$NAUTILUS_PYTHON_SCRIPTS"
        else
            printf "${RED}ERROR: Nautilus submenu '%s' already exists in %s${NC}\n" "$(basename "$file")" "$NAUTILUS_PYTHON_SCRIPTS"
            failed=true
        fi
    fi
done
[ "${failed-}" != "true" ] && printf "${GREEN}Nautilus python submenus installed succesfully${NC}\n"

# Restart nautilus
echo "Restarting nautilus..."
nautilus -q || :
