#!/bin/bash

# List of the packages to be installed and their descriptions
packages=(
    "duf:Disk Usage/Free Utility"
    "fzf:A general-purpose command-line fuzzy finder"
    "bpytop:Resource monitor that shows usage and stats for processor, memory, disks, network and processes"
    "htop:Interactive process viewer"
    "nano:Easy-to-use text editor"
    "tmux:A terminal multiplexer"
    "wget:A free utility for non-interactive download of files from the web"
    "curl:A tool to transfer data from or to a server"
    "git:A distributed version control system"
    "vim:A highly configurable text editor"
    "zsh:A shell designed for interactive use"
    "jq:A lightweight and flexible command-line JSON processor"
    "tree:A recursive directory listing command"
    "ncdu:A disk usage analyzer with an ncurses interface"
    "glances:A cross-platform system monitoring tool"
    "tldr:A collection of simplified and community-driven man pages"
    "neofetch:A command-line system information tool"
    "bat:A cat(1) clone with wings"
    "fd-find:A simple, fast and user-friendly alternative to 'find'"
    "ripgrep:A line-oriented search tool that recursively searches your current directory for a regex pattern"
    "fish:Smart and user-friendly command line shell"
    "emacs-nox:Extensible, customizable, free/libre text editor (no X version)"
    "lynx:A text-based web browser"
    "httrack:A free and easy-to-use offline browser utility"
    "silversearcher-ag:A code-searching tool similar to ack, but faster"
    "httpie:A user-friendly command-line HTTP client for the API era"
    "mtr:Network diagnostic tool"
    "iftop:Display bandwidth usage on an interface"
    "tcpdump:Command-line packet analyzer"
    "whois:Client for the whois directory service"
    "lsof:Utility to list open files"
    "strace:Trace system calls and signals"
    "sysstat:System performance tools for Linux"
    "dnsutils:DNS utilities provided by BIND"
    "net-tools:Networking utilities"
    "p7zip-full:File archiver with a high compression ratio"
    "tig:Text-mode interface for Git"
    "exa:Modern replacement for 'ls'"
    "eza:Modern replacement for 'ls'"
    "bmon:Bandwidth monitor and rate estimator"
    "ffmpeg:A complete solution to record, convert, and stream audio and video"
    "ssh:Secure shell client (remote login program)"
    "rsync:Fast, versatile, and remote file-copying tool"
)

# Set the debconf frontend to noninteractive
export DEBIAN_FRONTEND=noninteractive

# Set terminal to 'dumb', a minimalistic terminal type with limited capabilities
export TERM=dumb

# Update package list before installing the packages
apt-get update -y

# Loop through each package and install it
for package in "${packages[@]}"; do
    # Split the package name and description
    IFS=":" read -r name description <<< "$package"

    # Check if the package is already installed or not
    if dpkg -l | grep -q "^ii  $name "; then
        echo "$name ($description) is already installed"
    else
        # Try to install the package and print a message based on the result
        if sudo apt-get install -y "$name"; then
            echo "$name ($description) installed successfully"
        else
            echo "Failed to install $name ($description)"
            #exit 1 # Uncomment this line to stop the script if a package fails to install
        fi
    fi
done

# Remove the downloaded files for the installed packages
sudo apt-get autoremove -y
sudo apt-get clean

# Unset the debconf frontend to restore default behavior
unset DEBIAN_FRONTEND

# Worked on Debian 12 (stable) and Ubuntu 24.04; should work on other Debian-based distributions too
