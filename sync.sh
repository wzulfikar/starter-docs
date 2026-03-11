#!/bin/bash

# sync.sh - Copy boilerplate files from a starter project to a target directory
# Usage: ./sync.sh <project-name> [target-directory]
# Example: ./sync.sh expo /path-to-my-expo-project
# Example: ./sync.sh expo .        # sync to current directory
# Example: ./sync.sh expo          # same as above (defaults to current directory)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Show usage if no project name provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <project-name> [target-directory]"
    echo ""
    echo "Available projects:"
    for dir in "$SCRIPT_DIR"/*/; do
        if [ -d "$dir" ]; then
            basename "$dir"
        fi
    done
    echo ""
    echo "Examples:"
    echo "  $0 expo /path-to-my-expo-project  # sync to specific directory"
    echo "  $0 expo .                         # sync to current directory"
    echo "  $0 expo                           # same as above"
    exit 1
fi

PROJECT_NAME="$1"
TARGET_DIR="${2:-.}"
SOURCE_DIR="$SCRIPT_DIR/$PROJECT_NAME"

# Validate source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Project '$PROJECT_NAME' not found at $SOURCE_DIR"
    echo ""
    echo "Available projects:"
    for dir in "$SCRIPT_DIR"/*/; do
        if [ -d "$dir" ]; then
            basename "$dir"
        fi
    done
    exit 1
fi

# Handle '.' as current working directory (where script is called from)
if [ "$TARGET_DIR" = "." ]; then
    TARGET_DIR="$PWD"
elif [ ! -d "$TARGET_DIR" ]; then
    # Create target directory if it doesn't exist
    echo "Creating target directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# Convert target to absolute path if not already
if [ "${TARGET_DIR:0:1}" != "/" ]; then
    TARGET_DIR="$PWD/$TARGET_DIR"
fi

echo "Syncing files from '$PROJECT_NAME' to '$TARGET_DIR'..."

# Copy all files from source to target
# Using cp -R to preserve structure, excluding .git
if command -v rsync &> /dev/null; then
    rsync -av --exclude='.git' "$SOURCE_DIR/" "$TARGET_DIR/"
else
    # Fallback to cp + find (avoid copying .git)
    cd "$SOURCE_DIR"
    find . -type f -not -path './.git/*' -exec cp --parents {} "$TARGET_DIR/" \;
fi

echo "Done! Files synced to: $TARGET_DIR"
