#!/bin/bash

# Print header message
echo -e "\e[36mDecompressing all .7z, .rar, and .zip files in the current directory...\e[0m"

# Function to check if a command is available
check_dependency() {
    local cmd=$1
    local name=$2
    command -v "$cmd" >/dev/null 2>&1 || {
        echo -e "\e[31m$name is required but not installed. Install it and run the script again.\e[0m"
        echo -e "\e[31mRun this to install dependencies: sudo apt install p7zip-full unzip unrar-free unrar\e[0m"
        exit 1
    }
}

# Check for required dependencies
check_dependency "7z" "7z"
check_dependency "unrar" "unrar"
check_dependency "unzip" "unzip"

# Function to decompress files
decompress_file() {
    local file=$1
    case "$file" in
        *.7z)
            echo -e "\e[34mDecompressing $file...\e[0m"  # Blue color for .7z files
            7z x "$file"
            ;;
        *.rar)
            echo -e "\e[33mDecompressing $file...\e[0m"  # Yellow color for .rar files
            unrar x "$file"
            ;;
        *.zip)
            echo -e "\e[32mDecompressing $file...\e[0m"  # Green color for .zip files
            unzip "$file"
            ;;
        *)
            echo -e "\e[31mUnknown file format: $file\e[0m"  # Red color for unsupported files
            ;;
    esac
}

# Iterate over and decompress files
for file in *.{7z,rar,zip}; do
    [ -f "$file" ] && decompress_file "$file"
done

# Print completion message
echo -e "\e[36mDecompression complete.\e[0m"
