#!/bin/bash

# Copied from: https://gist.github.com/matthewjberger/7dd7e079f282f8138a9dc3b045ebefa0?permalink_comment_id=4005789#gistcomment-4005789

# See also: https://github.com/getnf/getnf

# Array of fonts to download
declare -a fonts=(
    BitstreamVeraSansMono
    CodeNewRoman
    DroidSansMono
    FiraCode
    FiraMono
    Go-Mono
    Hack
    Hermit
    JetBrainsMono
    Meslo
    Noto
    Overpass
    ProggyClean
    RobotoMono
    SourceCodePro
    SpaceMono
    Ubuntu
    UbuntuMono
)

# Version of Nerd Fonts to download
version='2.1.0'

# Directory where fonts will be installed
fonts_dir="${HOME}/.local/share/fonts"

# Create fonts directory if it does not exist
if [[ ! -d "$fonts_dir" ]]; then
    mkdir -p "$fonts_dir"
fi

# Loop through each font in the array
for font in "${fonts[@]}"; do
    # Construct URL and file names
    zip_file="${font}.zip"
    download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${zip_file}"

    # Download and install the font
    echo "Downloading $download_url"
    wget "$download_url"
    unzip "$zip_file" -d "$fonts_dir"
    rm "$zip_file"
done

# Clean up Windows compatible fonts (if any)
find "$fonts_dir" -name '*Windows Compatible*' -delete

# Update font cache
fc-cache -fv
