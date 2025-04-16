#!/bin/bash
set -euo pipefail

TREE_COMMAND="tree"
TARGET_EXTENSION=".py"
OUTPUT_FILE="concatenated_output.txt"

usage() {
  cat <<EOF
Usage: $0 [-e extension] [-o output_file] <directory_path>
  -e: File extension to concatenate (default: .py)
  -o: Output file name (default: concatenated_output.txt)
EOF
  exit 1
}

while getopts "e:o:" opt; do
  case $opt in
    e) TARGET_EXTENSION="$OPTARG" ;;
    o) OUTPUT_FILE="$OPTARG" ;;
    *) usage ;;
  esac
done

shift $((OPTIND-1))

if [ "$#" -ne 1 ]; then
  usage
fi

TARGET_DIR="$1"

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: '$TARGET_DIR' is not a valid directory."
  exit 1
fi

# Function to generate the directory structure output.
get_tree_structure() {
  local dir="$1"
  if command -v "$TREE_COMMAND" > /dev/null 2>&1; then
    if tree_output=$("$TREE_COMMAND" "$dir"); then
      echo "$tree_output"
      return 0
    fi
    echo "Failed to run '$TREE_COMMAND'. Trying alternative..."
  else
    echo "'$TREE_COMMAND' not found. Using alternative with 'find'..."
  fi

  # Fallback using find and sed
  if tree_output=$(cd "$dir" && find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'); then
    echo "$tree_output"
    return 0
  else
    echo "Error: Failed to generate directory structure." >&2
    return 1
  fi
}

# Write the directory structure and header to the output file.
{
  echo "--- Directory Structure ---"
  get_tree_structure "$TARGET_DIR"
  echo ""
  echo "--- File Contents ---"
  echo ""
} > "$OUTPUT_FILE"

# Concatenate file contents for files with the target extension.
while IFS= read -r -d $'\0' file; do
  {
    echo "--- Start of File: $file ---"
    cat "$file"
    echo ""
    echo "--- End of File: $file ---"
    echo ""
  } >> "$OUTPUT_FILE"
done < <(find "$TARGET_DIR" -type f -name "*$TARGET_EXTENSION" -print0)

echo "Processing complete. Output written to '$OUTPUT_FILE'."
exit 0
