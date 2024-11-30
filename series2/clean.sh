#!/bin/bash

# Define file names
CLONES_FILE="./clone-vis/public/clones.json"
RESULT_FILE="result.txt"

# Function to remove and recreate a file
manage_file() {
  local file=$1
  if [ -f "$file" ]; then
    echo "Removing $file..."
    rm "$file"
  else
    echo "$file does not exist. Creating it..."
  fi
  # Create an empty file
  touch "$file"
  echo "$file created successfully."
}

# Manage clones.json
manage_file "$CLONES_FILE"

# Manage result.txt
manage_file "$RESULT_FILE"

echo "All operations completed."
