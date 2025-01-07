#!/bin/bash

# The problem: In Ubuntu 24.04 LTS, the NVIDIA Unified Memory module (nvidia_uvm) sometimes fails to work correctly
# after a suspend (sleep). This script helps to fix the issue by removing and reinserting the module.

# Function to check the status of the last executed command
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Source: https://github.com/ollama/ollama/issues/3489#issuecomment-2094665760
# Commented out: Stopping the Ollama snap application
# echo "Stopping the Ollama snap application..."
# sudo snap stop ollama
# check_status "Failed to stop the Ollama snap application."

echo "Attempting to remove the nvidia_uvm module..."
sudo rmmod nvidia_uvm
check_status "Failed to remove the nvidia_uvm module."

# Verify if the nvidia_uvm module is still loaded
if lsmod | grep -q nvidia_uvm; then
    echo "The nvidia_uvm module is still loaded. Listing processes using /dev/nvidia-uvm..."
    sudo lsof /dev/nvidia-uvm
    check_status "Failed to list open files on /dev/nvidia-uvm."
    echo "Please stop or kill the processes using /dev/nvidia-uvm and rerun the script."
    exit 1
fi

echo "Reinserting the nvidia_uvm module..."
sudo modprobe nvidia_uvm
check_status "Failed to insert the nvidia_uvm module."

# Commented out: Starting the Ollama snap application
# echo "Starting the Ollama snap application..."
# sudo snap start ollama
# check_status "Failed to start the Ollama snap application."

echo "Displaying NVIDIA graphics card information..."
nvidia-smi
check_status "Failed to display NVIDIA graphics card information."

echo -e "\nUseful commands for troubleshooting:"
echo "1. 'pgrep -fa <pattern>' - Find the process ID and command of a running application by matching a pattern."
echo "2. 'sudo lsof /dev/nvidia-uvm' - List open files on /dev/nvidia-uvm to identify processes using the nvidia-uvm module."
echo "3. 'pkill -f <pattern>' - Kill a process using the command pattern found with 'pgrep -fa <pattern>'."
