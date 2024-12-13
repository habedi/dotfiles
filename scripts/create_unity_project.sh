#!/bin/bash

# Get the base directory from the first argument or use the current directory
BASE_DIR=${1:-"$(pwd)/"}

# Create the base project structure
mkdir -p "$BASE_DIR"/{Assets,Packages,ProjectSettings,Logs}

# Inside Assets
mkdir -p "$BASE_DIR/Assets"/{Art,Audio,Prefabs,Scenes,Scripts,UI,Plugins,Resources,Settings,ThirdParty}

# Inside Art
mkdir -p "$BASE_DIR/Assets/Art"/{Animations,Materials,Models,Textures}

# Inside Audio
mkdir -p "$BASE_DIR/Assets/Audio"/{Music,SoundEffects}

# Inside Scenes
mkdir -p "$BASE_DIR/Assets/Scenes"/{MainMenu,Levels,Sandbox}

# Inside Scripts
mkdir -p "$BASE_DIR/Assets/Scripts"/{Managers,Gameplay,UI,Utilities,Tests}

# Inside UI
mkdir -p "$BASE_DIR/Assets/UI"/{Fonts,Images,Prefabs}

# Create a text file with the structure and explanations
tree_structure="$BASE_DIR/structure.txt"
cat <<EOL > "$tree_structure"
Unity Project Structure
========================

- Assets/               : Main folder for all game assets.
  - Art/                : Visual assets.
    - Animations/       : Animation clips and controllers.
    - Materials/        : Materials for rendering.
    - Models/           : 3D models.
    - Textures/         : Textures for materials and UI.
  - Audio/              : Sound assets.
    - Music/            : Background music.
    - SoundEffects/     : Game sound effects.
  - Prefabs/            : Reusable prefabricated game objects.
  - Scenes/             : Game and testing scenes.
    - MainMenu/         : Scenes related to the main menu.
    - Levels/           : Game levels.
    - Sandbox/          : Testing or prototype scenes.
  - Scripts/            : Code for game logic and utilities.
    - Managers/         : Game-wide managers (e.g., GameManager).
    - Gameplay/         : Core gameplay mechanics.
    - UI/               : Scripts related to user interface.
    - Utilities/        : Helper scripts (e.g., math helpers).
    - Tests/            : Unit or integration tests.
  - UI/                 : UI assets.
    - Fonts/            : Custom fonts.
    - Images/           : UI icons and images.
    - Prefabs/          : Prefabricated UI components.
  - Plugins/            : Third-party plugins.
  - Resources/          : Assets loaded dynamically during runtime.
  - Settings/           : Configuration files and settings.
  - ThirdParty/         : Third-party assets or libraries.

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
