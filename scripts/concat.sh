#!/bin/bash
set -euo pipefail

# Example usages:
# concat.sh -e .c,.h -o concatenated_files_output.txt -t .
# concat.sh -e .c,.h -o concatenated_files_output.txt -t src,include
# concat.sh -e .py -o concatenated_files_output.txt -x .venv,venv -t .

TREE_COMMAND="tree"
TARGET_EXTENSIONS=(".py")
OUTPUT_FILE="concatenated_output.txt"
PRINT_TREE=false
EXCLUDE_PATTERNS=()

usage() {
  cat <<EOF
Usage: $0 [-e extensions] [-o output_file] [-x exclude_patterns] [-t] <directory_path(s)>
  -e: Comma-separated list of file extensions (e.g., .c,.h,.cpp). Default: .py
  -o: Output file name (default: concatenated_output.txt)
  -x: Comma-separated list of patterns to exclude (e.g., .venv,venv,node_modules)
  -t: Print tree structure to output (optional)
  directory_path(s): Single directory or comma-separated list of directories
EOF
  exit 1
}

while getopts "e:o:x:t" opt; do
  case $opt in
    e) IFS=',' read -r -a TARGET_EXTENSIONS <<< "$OPTARG" ;;
    o) OUTPUT_FILE="$OPTARG" ;;
    x) IFS=',' read -r -a EXCLUDE_PATTERNS <<< "$OPTARG" ;;
    t) PRINT_TREE=true ;;
    *) usage ;;
  esac
done

shift $((OPTIND-1))

if [ "$#" -ne 1 ]; then
  usage
fi

# Check if the argument contains commas, and split it if it does
if [[ "$1" == *,* ]]; then
  IFS=',' read -r -a TARGET_PATHS <<< "$1"
else
  TARGET_PATHS=("$1")
fi

# Verify all specified paths exist
for dir in "${TARGET_PATHS[@]}"; do
  if [[ ! -d "$dir" ]]; then
    echo "Error: '$dir' is not a valid directory."
    exit 1
  fi
done

get_tree_structure() {
  local dir="$1"
  if command -v "$TREE_COMMAND" > /dev/null 2>&1; then
    local exclude_args=()
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
      exclude_args+=(-I "$pattern")
    done
    "$TREE_COMMAND" "${exclude_args[@]}" "$dir"
  else
    echo "'$TREE_COMMAND' not found. Using fallback with 'find'..."
    local exclude_args=()
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
      exclude_args+=(-not -path "*/$pattern/*")
    done
    (cd "$dir" && find . "${exclude_args[@]}" -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g')
  fi
}

# Write header and optional tree structure to the output file
{
  if [ "$PRINT_TREE" = true ]; then
    echo "--- Directory Structure ---"
    for dir in "${TARGET_PATHS[@]}"; do
      echo "Structure for directory: $dir"
      get_tree_structure "$dir"
      echo ""
    done
  fi

  echo "--- File Contents ---"
  echo ""
} > "$OUTPUT_FILE"

# Build find expression for extensions
find_ext_expr=()
for ext in "${TARGET_EXTENSIONS[@]}"; do
  find_ext_expr+=(-name "*$ext" -o)
done
unset 'find_ext_expr[${#find_ext_expr[@]}-1]'  # remove trailing -o

# Build find expression for exclusions
find_excl_expr=()
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
  find_excl_expr+=(-not -path "*/$pattern/*")
done

# Process each target path
for dir in "${TARGET_PATHS[@]}"; do
  # Concatenate file contents from this directory
  while IFS= read -r -d $'\0' file; do
    {
      echo "--- Start of File: $file ---"
      cat "$file"
      echo ""
      echo "--- End of File: $file ---"
      echo ""
    } >> "$OUTPUT_FILE"
  done < <(find "$dir" -type f \( "${find_ext_expr[@]}" \) "${find_excl_expr[@]}" -print0)
done

echo "Processing complete. Output written to '$OUTPUT_FILE'."
exit 0
