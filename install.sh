#!/bin/sh
set -eu

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

if ! type nautilus >/dev/null 2>&1; then
    printf "${RED}Nautilus is not installed, abort${NC}\n"
    exit 1
fi

printf_install() {
    printf "${GREEN}Download python-nautilus${NC}\n"
}

# Install python-nautilus
if type pacman >/dev/null 2>&1; then
    # Check if already install, else install
    if [ -z "$(pacman -Qi python-nautilus 2>/dev/null || :)" ]; then
        printf_install
        sudo pacman -S --noconfirm python-nautilus
    fi
elif type apt >/dev/null 2>&1; then
    # # Find Ubuntu python-nautilus package
    # package_name="python3-nautilus"
    # found_package=$(apt-cache search --names-only $package_name)
    # if [ -z "$found_package" ]; then
    #     package_name="python3-nautilus"
    # fi

    # Check if already install, else install
    if [ -z "$(apt list --installed python3-nautilus -qq 2>/dev/null)" ]; then
        printf_install
        sudo apt install -y python3-nautilus
    fi
elif type dnf >/dev/null 2>&1; then
    # Check if already install, else install
    if [ -z "$(dnf list --installed nautilus-python 2>/dev/null)" ]; then
        printf_install
        sudo dnf install -y nautilus-python
    fi
else
    printf "${RED}Pkg manager not supported, make sure 'python-nautilus' is installed${NC}\n"
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
            restart_nautilus=true
        else
            printf "${RED}ERROR: Nautilus submenu '%s' already exists in %s${NC}\n" "$(basename "$file")" "$NAUTILUS_PYTHON_SCRIPTS"
            failed=true
        fi
    fi
done

# Restart nautilus
[ "${restart_nautilus-}" = "true" ] &&
    {
        echo "Restarting nautilus..."
        nautilus -q
    }

[ "${failed-}" != "true" ] && printf "${GREEN}Nautilus python submenus installed succesfully${NC}\n"
