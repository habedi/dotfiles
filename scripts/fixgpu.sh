#!/bin/bash

# Fix NVIDIA Unified Memory module (nvidia_uvm) issues after suspend (sleep) in Ubuntu 24.04 LTS.
# This script attempts to remove and reinsert the nvidia_uvm module to resolve the problem.

# Function: Display useful troubleshooting commands.
show_useful_info() {
    echo -e "\nUseful troubleshooting commands:"
    echo "1. 'pgrep -fa <pattern>' - Find processes by matching a pattern."
    echo "2. 'sudo lsof /dev/nvidia-uvm' - List processes using the nvidia_uvm module."
    echo "3. 'pkill -f <pattern>' - Terminate processes using the command pattern from 'pgrep -fa'."
}

# Function: Check the status of the last executed command and exit on failure.
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        show_useful_info
        exit 1
    fi
}

# Source: https://github.com/ollama/ollama/issues/3489#issuecomment-2094665760

# Uncomment these lines if you need to stop/start specific applications before/after fixing the module.
 echo "Stopping the Ollama snap application..."
 sudo snap stop ollama
 check_status "Failed to stop the Ollama snap application."

echo "Removing the nvidia_uvm module..."
sudo rmmod nvidia_uvm
check_status "Failed to remove the nvidia_uvm module."

# Check if the nvidia_uvm module is still loaded.
if lsmod | grep -q nvidia_uvm; then
    echo "The nvidia_uvm module is still loaded. Listing processes using /dev/nvidia-uvm..."
    sudo lsof /dev/nvidia-uvm
    check_status "Failed to list processes using /dev/nvidia-uvm."
    echo "Please stop or terminate the processes using /dev/nvidia-uvm, then rerun the script."
    exit 1
fi

echo "Reinserting the nvidia_uvm module..."
sudo modprobe nvidia_uvm
check_status "Failed to insert the nvidia_uvm module."

# Uncomment these lines if you need to restart specific applications after fixing the module.
 echo "Starting the Ollama snap application..."
 sudo snap start ollama
 check_status "Failed to start the Ollama snap application."

echo "Displaying NVIDIA graphics card information with nvidia-smi..."
nvidia-smi
check_status "Failed to retrieve NVIDIA graphics card information."

echo "nvidia_uvm module successfully reloaded and NVIDIA graphics card is operational."
