#!/bin/bash

# A script to install a few cool command-line tools on your Linux machine; great to show off your hacker skills

set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install a package using apt
install_apt_package() {
    if ! command_exists "$1"; then
        echo "Installing $1..."
        sudo apt install -y "$1"
    else
        echo "$1 is already installed."
    fi
}

# Function to install a package using snap
install_snap_package() {
    if ! command_exists "$1"; then
        echo "Installing $1..."
        sudo snap install "$1"
    else
        echo "$1 is already installed."
    fi
}

# Function to install TEXTREME
install_textreme() {
    echo "Installing TEXTREME..."
    TEXTREME_URL="https://example.com/path/to/textreme.tar.gz"  # Replace with actual URL
    wget $TEXTREME_URL -O /tmp/textreme.tar.gz
    tar -xzf /tmp/textreme.tar.gz -C /opt/
    echo "Alias added for TEXTREME. Run 'textreme' to start."
}

# Function to install No More Secrets
install_no_more_secrets() {
    echo "Installing No More Secrets..."
    git clone https://github.com/bartobri/no-more-secrets.git /tmp/no-more-secrets
    cd /tmp/no-more-secrets
    make nms
    make sneakers
    sudo make install
    cd -
}

# Update package list
echo "Updating package list..."
sudo apt update

# Install tools
install_snap_package genact
install_snap_package gping

install_apt_package cmatrix
install_apt_package hollywood
install_apt_package cool-retro-term
install_apt_package bpytop

#install_textreme
#install_no_more_secrets

# Cleanup
sudo apt autoremove
sudo apt clean

echo "All tools have been installed. Enjoy looking like a hacker!"
