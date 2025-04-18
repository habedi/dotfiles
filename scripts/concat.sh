#!/bin/bash
set -euo pipefail

# Example usage:
# concat.sh -e .c,.h -o concatenated_files_output.txt -t .

TREE_COMMAND="tree"
TARGET_EXTENSIONS=(".py")
OUTPUT_FILE="concatenated_output.txt"
PRINT_TREE=false

usage() {
  cat <<EOF
Usage: $0 [-e extensions] [-o output_file] [-t] <directory_path>
  -e: Comma-separated list of file extensions (e.g., .c,.h,.cpp). Default: .py
  -o: Output file name (default: concatenated_output.txt)
  -t: Print tree structure to output (optional)
EOF
  exit 1
}

while getopts "e:o:t" opt; do
  case $opt in
    e) IFS=',' read -r -a TARGET_EXTENSIONS <<< "$OPTARG" ;;
    o) OUTPUT_FILE="$OPTARG" ;;
    t) PRINT_TREE=true ;;
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

get_tree_structure() {
  local dir="$1"
  if command -v "$TREE_COMMAND" > /dev/null 2>&1; then
    "$TREE_COMMAND" "$dir"
  else
    echo "'$TREE_COMMAND' not found. Using fallback with 'find'..."
    (cd "$dir" && find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g')
  fi
}

# Write header and optional tree structure to the output file
{
  if [ "$PRINT_TREE" = true ]; then
    echo "--- Directory Structure ---"
    get_tree_structure "$TARGET_DIR"
    echo ""
  fi

  echo "--- File Contents ---"
  echo ""
} > "$OUTPUT_FILE"

# Build find expression
find_expr=()
for ext in "${TARGET_EXTENSIONS[@]}"; do
  find_expr+=(-name "*$ext" -o)
done
unset 'find_expr[${#find_expr[@]}-1]'  # remove trailing -o

# Concatenate file contents
while IFS= read -r -d $'\0' file; do
  {
    echo "--- Start of File: $file ---"
    cat "$file"
    echo ""
    echo "--- End of File: $file ---"
    echo ""
  } >> "$OUTPUT_FILE"
done < <(find "$TARGET_DIR" -type f \( "${find_expr[@]}" \) -print0)

echo "Processing complete. Output written to '$OUTPUT_FILE'."
exit 0
