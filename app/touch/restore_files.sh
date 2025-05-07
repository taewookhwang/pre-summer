#!/bin/bash

# This script restores the original files that were backed up
# by the minimal_build.sh script

echo "Restoring original files..."

TEMP_DIR="./temp_backups"

# Check if backup directory exists
if [ ! -d "$TEMP_DIR" ]; then
    echo "Error: Backup directory $TEMP_DIR not found!"
    exit 1
fi

# Find all backed up files
find "$TEMP_DIR" -name "*.bak" | while read backup_file; do
    # Get the original path
    original_path=${backup_file%.bak}
    original_path=${original_path#"$TEMP_DIR/"}
    
    # Remove the placeholder file/directory if it exists
    if [ -e "$original_path" ]; then
        rm -rf "$original_path"
    fi
    
    # Make sure parent directory exists
    parent_dir=$(dirname "$original_path")
    mkdir -p "$parent_dir"
    
    # Move the backup back to its original location
    echo "Restoring $original_path"
    mv "$backup_file" "$original_path"
done

# Clean up empty directories in the backup location
rm -rf "$TEMP_DIR"

echo "Original files restored!"
