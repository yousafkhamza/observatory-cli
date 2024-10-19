#!/bin/bash

# Author: Yousaf
# Date: 2024
# Description: This script checks the security headers of a given URL.
# Usage: ./script.sh <url>
# Ensure the URL starts with http:// or https://
# It fetches the headers and evaluates the presence of important security headers.
# The script also calculates a score based on the headers found.

# URL for the script in raw format
SCRIPT_URL="https://raw.githubusercontent.com/yousafkhamza/observatory-cli/main/script.sh"

# Installation directory
INSTALL_DIR="$HOME/observatory"
SCRIPT_PATH="$INSTALL_DIR/observatory-cli.sh"
LINK_PATH="/usr/local/bin/observatory-checker"

# Check if the application is already installed
if [ -f "$SCRIPT_PATH" ]; then
  echo "The Observatory-CLI is already installed at $SCRIPT_PATH."
  echo "You can run it using the command: 'observatory-checker <url>'."
  exit 0
fi

# Create the directory for the application
mkdir -p "$INSTALL_DIR"

# Download the script
curl -sSL "$SCRIPT_URL" -o "$SCRIPT_PATH"

# Make the script executable
chmod +x "$SCRIPT_PATH"

# Check if the symlink already exists
if [ -L "$LINK_PATH" ]; then
  echo "The command 'observatory-checker' is already available in your PATH."
else
  # Create a symlink in /usr/local/bin for easy access
  sudo ln -s "$SCRIPT_PATH" "$LINK_PATH"
  echo "Installation complete! You can now run the Observatory-CLI using the command 'observatory-checker <url>'."
fi
