#!/bin/bash

# Set the base directory from the first argument or default to the current directory
BASE_DIR=${1:-"$(pwd)/"}

# Function to create a directory and handle errors
create_dir() {
    mkdir -p "$1" || {
        echo "Error creating directory: $1"
        exit 1
    }
}

# Create the base project structure
echo "Creating Unity project structure..."
create_dir "$BASE_DIR/Assets"
create_dir "$BASE_DIR/Packages"
create_dir "$BASE_DIR/ProjectSettings"
create_dir "$BASE_DIR/Logs"

# Create subdirectories under Assets
echo "Creating subdirectories under Assets..."
create_dir "$BASE_DIR/Assets/Art"
create_dir "$BASE_DIR/Assets/Audio"
create_dir "$BASE_DIR/Assets/Prefabs"
create_dir "$BASE_DIR/Assets/Scenes"
create_dir "$BASE_DIR/Assets/Scripts"
create_dir "$BASE_DIR/Assets/UI"
create_dir "$BASE_DIR/Assets/Plugins"
create_dir "$BASE_DIR/Assets/Resources"
create_dir "$BASE_DIR/Assets/Settings"
create_dir "$BASE_DIR/Assets/ThirdParty"

# Inside Art
create_dir "$BASE_DIR/Assets/Art/Animations"
create_dir "$BASE_DIR/Assets/Art/Materials"
create_dir "$BASE_DIR/Assets/Art/Models"
create_dir "$BASE_DIR/Assets/Art/Textures"

# Inside Audio
create_dir "$BASE_DIR/Assets/Audio/Music"
create_dir "$BASE_DIR/Assets/Audio/SoundEffects"

# Inside Scenes
create_dir "$BASE_DIR/Assets/Scenes/MainMenu"
create_dir "$BASE_DIR/Assets/Scenes/Levels"
create_dir "$BASE_DIR/Assets/Scenes/Sandbox"

# Inside Scripts
create_dir "$BASE_DIR/Assets/Scripts/Managers"
create_dir "$BASE_DIR/Assets/Scripts/Gameplay"
create_dir "$BASE_DIR/Assets/Scripts/UI"
create_dir "$BASE_DIR/Assets/Scripts/Utilities"
create_dir "$BASE_DIR/Assets/Scripts/Tests"

# Inside UI
create_dir "$BASE_DIR/Assets/UI/Fonts"
create_dir "$BASE_DIR/Assets/UI/Images"
create_dir "$BASE_DIR/Assets/UI/Prefabs"

# Create structure explanation file
tree_structure="$BASE_DIR/structure.txt"
echo "Writing structure explanation to $tree_structure..."
cat <<EOL > "$tree_structure"
Unity Project Structure
========================

- Assets/               : Main folder for all game assets.
  - Art/                : Visual assets (animations, models, textures).
  - Audio/              : Sound assets (music and sound effects).
  - Prefabs/            : Reusable prefabricated game objects.
  - Scenes/             : Game and testing scenes.
  - Scripts/            : Code for game logic and utilities.
  - UI/                 : UI-related assets.
  - Plugins/            : Third-party plugins.
  - Resources/          : Dynamically loaded runtime assets.
  - Settings/           : Configuration files.
  - ThirdParty/         : External libraries and assets.

- Packages/             : Unity Package Manager dependencies.
- ProjectSettings/      : Project settings and configuration.
- Logs/                 : Log files (optional).
EOL

# Create `.gitignore` file
gitignore_file="$BASE_DIR/.gitignore"
cat <<EOL > "$gitignore_file"
# Unity generated files
[Ll]ibrary/
[Tt]emp/
[Oo]bj/
[Bb]uild/
[Bb]uilds/
[Ll]ogs/
[Mm]emoryCaptures/
# Visual Studio
*.csproj
*.unityproj
*.sln
*.suo
*.tmp
*.user
*.userprefs
*.pidb
*.booproj
*.svd
# JetBrains Rider
.idea/
# OS generated files
.DS_Store
Thumbs.db
EOL

# Create `.gitattributes` file
gitattributes_file="$BASE_DIR/.gitattributes"
cat <<EOL > "$gitattributes_file"
# Set default behaviour to automatically merge binary files
* text=auto
# Unity YAML files
*.unity merge=unityyaml
*.asset merge=unityyaml
*.prefab merge=unityyaml
*.mat merge=unityyaml
*.anim merge=unityyaml
*.physicsMaterial merge=unityyaml
*.physicsMaterial2D merge=unityyaml
# Image files
*.png binary
*.jpg binary
*.jpeg binary
*.psd binary
*.tga binary
*.tif binary
*.tiff binary
*.gif binary
*.bmp binary
*.exr binary
# Audio files
*.mp3 binary
*.wav binary
*.ogg binary
# Model files
*.fbx binary
*.obj binary
*.dae binary
*.3ds binary
*.dxf binary
*.max binary
*.blend binary
EOL

# Create `ignore.conf` file for Plastic SCM
ignore_conf_file="$BASE_DIR/ignore.conf"
cat <<EOL > "$ignore_conf_file"
Library
library
Temp
temp
Obj
obj
Build
build
Builds
builds
UserSettings
usersettings
MemoryCaptures
memorycaptures
Logs
logs
**/Assets/AssetStoreTools
**/assets/assetstoretools
/Assets/Plugins/PlasticSCM*
/assets/plugins/PlasticSCM*
*.private
*.private.meta
^*.private.[0-9]+
^*.private.[0-9]+.meta
.vs
.vscode
.idea
.gradle
ExportedObj
.consulo
*.csproj
*.unityproj
*.sln
*.suo
*.tmp
*.user
*.userprefs
*.pidb
*.booproj
*.svd
*.pdb
*.mdb
*.opendb
*.VC.db
*.pidb.meta
*.pdb.meta
*.mdb.meta
sysinfo.txt
crashlytics-build.properties
*.apk
*.aab
*.app
*.unitypackage
~UnityDirMonSyncFile~*
**/Assets/AddressableAssetsData/*/*.bin*
**/assets/addressableassetsdata/*/*.bin*
**/Assets/StreamingAssets/aa.meta
**/assets/streamingassets/*/aa/*
.DS_Store*
Thumbs.db
Desktop.ini
EOL

# Print completion message
echo "Unity project structure created successfully in the '$BASE_DIR' directory."
echo "See '$tree_structure' for information on the project structure."
echo ".gitignore, .gitattributes, and ignore.conf files created successfully."
echo "You can start building your Unity project now! 🚀 🎮 🎉"
