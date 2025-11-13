#!/usr/bin/env bash
set -euo pipefail

# Example usages:
#   ./concat.sh -e .c,.h -o concatenated_output.txt -t src include
#   ./concat.sh -e .py -o all_py.txt -x .venv,node_modules -t .

# Default settings
TREE_CMD="tree"
EXTENSIONS=(".py")
OUTPUT="concatenated_output.txt"
PRINT_TREE=false
EXCLUDE_DIRS=()

print_usage() {
  cat <<EOF
Usage: $0 [-e ext1,ext2,...] [-o output_file] [-x exclude1,exclude2,...] [-t] <dir1> [<dir2> ...]

  -e  Comma-separated list of extensions (e.g., .c,.h,.cpp). Default: .py
  -o  Output file path. Default: concatenated_output.txt
  -x  Comma-separated list of directories (or nested paths) to skip.
      Examples: .venv,node_modules,src/graphql_handler/tests
  -t  Show a directory tree (requires 'tree'; falls back to 'find').

  <dir1> [<dir2> ...]  One or more existing directories to scan.
EOF
  exit 1
}

# Parse options
while getopts "e:o:x:t" opt; do
  case "$opt" in
    e)
      IFS=',' read -r -a EXTENSIONS <<< "$OPTARG"
      ;;
    o)
      OUTPUT="$OPTARG"
      ;;
    x)
      IFS=',' read -r -a EXCLUDE_DIRS <<< "$OPTARG"
      ;;
    t)
      PRINT_TREE=true
      ;;
    *)
      print_usage
      ;;
  esac
done
shift $((OPTIND - 1))

# Need at least one target directory
if [ "$#" -lt 1 ]; then
  echo "Error: at least one directory is required."
  print_usage
fi

# Verify and collect target directories
TARGET_DIRS=()
for arg in "$@"; do
  if [ ! -d "$arg" ]; then
    echo "Error: '$arg' is not a directory."
    exit 1
  fi
  TARGET_DIRS+=("$arg")
done

# Ensure parent directory of OUTPUT exists
OUTPUT_PARENT="$(dirname "$OUTPUT")"
if [ "$OUTPUT_PARENT" != "." ]; then
  mkdir -p "$OUTPUT_PARENT"
fi

# Prevent including the output file in the find results by pruning it
OUTPUT_BASENAME="$(basename "$OUTPUT")"
EXCLUDE_DIRS+=("$OUTPUT_BASENAME")

# Build an array of lines to be used as prune expressions.
# Each line printed is one element of the future prune array.
build_prune_array() {
  local tmp=()
  if [ "${#EXCLUDE_DIRS[@]}" -eq 0 ]; then
    printf '%s\n' "${tmp[@]}"
    return
  fi

  tmp+=( "(" )
  for d in "${EXCLUDE_DIRS[@]}"; do
    tmp+=( -path "*/$d" -o )
  done
  unset 'tmp[${#tmp[@]}-1]'  # remove trailing -o
  tmp+=( ")" "-prune" "-o" )

  printf '%s\n' "${tmp[@]}"
}

# Build an array of lines to be used as extension-matching expressions.
# If EXTENSIONS contains a single empty string, we treat it as "match all" (i.e. no filter).
build_ext_array() {
  local tmp=()
  if [ "${#EXTENSIONS[@]}" -eq 1 ] && [ -z "${EXTENSIONS[0]}" ]; then
    # No extension filtering
    printf '%s\n' "${tmp[@]}"
    return
  fi

  for ext in "${EXTENSIONS[@]}"; do
    # Make sure ext starts with a dot; if not, prepend it
    if [[ "$ext" != .* ]]; then
      ext=".$ext"
    fi
    tmp+=( -iname "*$ext" -o )
  done
  unset 'tmp[${#tmp[@]}-1]'  # remove trailing -o

  printf '%s\n' "${tmp[@]}"
}

# Print a directory tree for one directory, skipping excluded names
print_tree() {
  local dir="$1"
  echo "Directory structure for: $dir"
  if command -v "$TREE_CMD" &>/dev/null; then
    local IARGS=()
    for d in "${EXCLUDE_DIRS[@]}"; do
      IARGS+=( -I "$d" )
    done
    "$TREE_CMD" "${IARGS[@]}" "$dir"
  else
    # Fallback: use find + sed, but only show directories (omit files)
    local prune_lines
    IFS=$'\n' read -r -d '' -a prune_lines < <(build_prune_array && printf '\0')
    (cd "$dir" && find . "${prune_lines[@]}" -type d -print | \
      sed -e 's;[^/]*/;|___;g;s;___|; |;g')
  fi
  echo ""
}

# Write header (tree + file contents) to the output file
{
  if [ "$PRINT_TREE" = true ]; then
    echo "--- Directory Trees ---"
    for d in "${TARGET_DIRS[@]}"; do
      print_tree "$d"
    done
  fi
  echo "--- File Contents ---"
  echo ""
} > "$OUTPUT"

# Main loop: find matching files under each target dir, skipping pruned paths
for d in "${TARGET_DIRS[@]}"; do
  # Build prune array for this directory
  IFS=$'\n' read -r -d '' -a prune_arr < <(build_prune_array && printf '\0')

  # Build extension array for this directory
  IFS=$'\n' read -r -d '' -a ext_arr < <(build_ext_array && printf '\0')

  # Construct find command arguments step by step:
  find_args=( "$d" )
  if [ "${#prune_arr[@]}" -gt 0 ]; then
    find_args+=( "${prune_arr[@]}" )
  fi

  find_args+=( -type f )
  if [ "${#ext_arr[@]}" -gt 0 ]; then
    find_args+=( "(" "${ext_arr[@]}" ")" )
  fi

  find_args+=( -print0 )

  # Execute find and append each file's contents
  find "${find_args[@]}" | \
    while IFS= read -r -d '' file; do
      {
        echo "----- Begin: $file -----"
        cat "$file"
        echo ""
        echo "-----  End: $file  -----"
        echo ""
      } >> "$OUTPUT"
    done
done

echo "Done. Output is in '$OUTPUT'."
exit 0
