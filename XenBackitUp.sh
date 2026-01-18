#!/bin/bash

# ==============================================================================
# AUTHOR:       Atif Mumtaz              
# DATE:         2024-05-22
# Name:         XenBackitUp
# VERSION:      0.4
# DESCRIPTION:  A robust backup script that archives specific web project 
#               folders while excluding heavy/unnecessary directories. 
#               
# PLATFORM:     Optimized for macOS (BSD Tar) and Linux (GNU Tar).
# ==============================================================================

# --- SAFETY SETTINGS ---
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error.
# -o pipefail: Ensure errors in a pipeline (like du | awk) are caught.

set -euo pipefail

# --- CONFIGURATION ---

# 1. Absolute paths to the source folders you want to backup.
SOURCE_FOLDERS=(
  "/root/home/username/Public/myproject_a"
  "/root/home/username/myproject_b"
  "/root/home/username/Public/myproject_c"
)

# 2. Destination directory where .tgz files will be stored.
OUTPUT_DIR="/offline/backups/projects"

# 3. Items to exclude from every archive. 
# NOTE: These are patterns. Tar will skip any folder/file matching these names.
GLOBAL_EXCLUDES=(
  "venv"
  ".data_store"
  "node_modules"
  ".git"
  "temp_cache"
  ".DS_Store" # Common macOS hidden file to exclude
)

# --- ARCHIVING FUNCTION ---

archive_folder() {
  # Assigning local variables for clarity and scope protection
  local SOURCE_PATH="$1"
  local FOLDER_BASENAME=$(basename "$SOURCE_PATH") # The folder name (e.g., 'jaroka')
  local PARENT_DIR=$(dirname "$SOURCE_PATH")      # The path leading to it
  local DATE_STRING=$(date +%Y-%m-%d_%H-%M-%S)
  local OUTPUT_FILE="${OUTPUT_DIR}/${FOLDER_BASENAME}_${DATE_STRING}.tgz"
  
  echo -e "\n--- Processing: ${FOLDER_BASENAME} ---"
  
  # Validation: Check if the source directory actually exists
  if [[ ! -d "$SOURCE_PATH" ]]; then
    echo "ERROR: Source folder not found: ${SOURCE_PATH}"
    return 1
  fi

  # COMMAND CONSTRUCTION (The Array Method)
  # We use an array instead of a string to handle spaces and quotes safely.
  # -c: Create, -z: Gzip compression, -v: Verbose, -f: Filename
  local TAR_ARGS=(-czvf "$OUTPUT_FILE")

  # Dynamically add exclude flags from the GLOBAL_EXCLUDES array
  for EXCLUDE_ITEM in "${GLOBAL_EXCLUDES[@]}"; do
    TAR_ARGS+=(--exclude="$EXCLUDE_ITEM")
  done

  # ADD SOURCE INFO:
  # -C (Change Directory) tells tar to "jump" into the parent folder first.
  # This ensures the archive contains 'jaroka/' and not 'Users/amumtaz/.../jaroka/'
  TAR_ARGS+=(-C "$PARENT_DIR" "$FOLDER_BASENAME")

  echo "Target: ${OUTPUT_FILE}"
  
  # Execute the tar command by expanding the array
  tar "${TAR_ARGS[@]}"

  # --- POST-PROCESSING: SIZE CALCULATION ---
  # Check if the file was successfully created before measuring it
  if [[ -f "$OUTPUT_FILE" ]]; then
    # 'du -h' provides human-readable size (e.g., 150M). 
    # 'awk' takes the first column and ignores the file path.
    FILE_SIZE=$(du -h "$OUTPUT_FILE" | awk '{print $1}')
    echo "Status: Archive complete. Size: ${FILE_SIZE}"
  else
    echo "Status: Failed to create archive."
  fi
}

# --- MAIN SCRIPT EXECUTION ---

# Create the output directory if it doesn't already exist (-p prevents errors)
echo "Ensuring output directory exists: ${OUTPUT_DIR}"
mkdir -p "$OUTPUT_DIR"

# Iterate through the list of folders provided in the configuration
for FOLDER_PATH in "${SOURCE_FOLDERS[@]}"; do
  # Call the archive function. The '|| true' ensures that if one folder 
  # fails, the script continues to the next folder in the list.
  archive_folder "$FOLDER_PATH" || echo "Warning: Failed to backup $FOLDER_PATH"
done

echo -e "\n*** All archiving tasks complete. ***"