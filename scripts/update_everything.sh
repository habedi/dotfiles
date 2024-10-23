#!/bin/bash

# Make sure these packages are already installed
# apt install sudo flatpak snapd zsh git curl wget unzip -y

# Load the user's profile
echo -e "\033[1;34mLoading user's profile...\033[0m"
# shellcheck disable=SC1090
source ~/.profile

# Update APT packages
echo -e "\033[1;32mUpdating APT packages...\033[0m"
sudo apt update && sudo apt upgrade -y

# Update Snap packages
echo -e "\033[1;32mUpdating Snap packages...\033[0m"
sudo snap refresh

# Update Flatpak packages
echo -e "\033[1;32mUpdating Flatpak packages...\033[0m"
flatpak update -y

# Update Python packages installed via pipx
echo -e "\033[1;32mUpdating Python packages installed via pipx...\033[0m"
pipx upgrade-all

# Update tools installed via uv
echo -e "\033[1;32mUpdating tools installed via uv...\033[0m"
uv tool upgrade --all

## Update GNU Guix system and user profiles
# echo -e "\033[1;32mUpdating GNU Guix system and user profiles...\033[0m"
# guix pull && guix package -u
