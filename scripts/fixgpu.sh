#!/bin/bash

# Fix NVIDIA Unified Memory module (nvidia_uvm) issues after suspend (sleep) in Ubuntu 24.04 LTS.
# This script attempts to remove and reinsert the nvidia_uvm module to resolve the problem.

# Function: Check the status of the last executed command and exit on failure.
check_status() {
    if [ $? -ne 0 ]; then
        echo -e "\e[31mError: $1\e[0m"  # Red color for errors
        echo -e "\n\e[33mUseful troubleshooting commands:\e[0m"  # Yellow color for headings
        echo -e "\e[32m1. 'pgrep -fa <pattern>' - Find processes by matching a pattern.\e[0m"
        echo -e "\e[32m2. 'sudo lsof /dev/nvidia-uvm' - List processes using the nvidia_uvm module.\e[0m"
        echo -e "\e[32m3. 'pkill -f <pattern>' - Terminate processes using the command pattern from 'pgrep -fa'.\n\e[0m"
    fi
}

# Source: https://github.com/ollama/ollama/issues/3489#issuecomment-2094665760

# Uncomment these lines if you need to stop/start specific applications before/after fixing the module.
echo -e "\e[34mStopping the Ollama snap application...\e[0m"  # Blue color for actions
sudo snap stop ollama
check_status "Failed to stop the Ollama snap application."

echo -e "\e[34mRemoving the nvidia_uvm module...\e[0m"
sudo rmmod nvidia_uvm
check_status "Failed to remove the nvidia_uvm module."

# Check if the nvidia_uvm module is still loaded.
if lsmod | grep -q nvidia_uvm; then
    echo -e "\e[34mThe nvidia_uvm module is still loaded. Listing processes using /dev/nvidia-uvm...\e[0m"
    sudo lsof /dev/nvidia-uvm
    check_status "Failed to list processes using /dev/nvidia-uvm."
fi

echo -e "\e[34mReinserting the nvidia_uvm module...\e[0m"
sudo modprobe nvidia_uvm
check_status "Failed to insert the nvidia_uvm module."

# Uncomment these lines if you need to restart specific applications after fixing the module.
echo -e "\e[34mStarting the Ollama snap application...\e[0m"
sudo snap start ollama
check_status "Failed to start the Ollama snap application."

echo -e "\e[34mDisplaying NVIDIA graphics card information with nvidia-smi...\e[0m"
nvidia-smi
check_status "Failed to retrieve NVIDIA graphics card information."

echo -e "\e[32mnvidia_uvm module successfully reloaded and NVIDIA graphics card is operational.\e[0m"  # Green color for success
