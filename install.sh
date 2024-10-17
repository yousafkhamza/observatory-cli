#!/bin/bash

# URL for the script in raw format
SCRIPT_URL="https://raw.githubusercontent.com/yousafkhamza/header-checker/main/check_headers.sh"

# Installation directory
INSTALL_DIR="$HOME/header-checker"
SCRIPT_PATH="$INSTALL_DIR/check_headers.sh"
LINK_PATH="/usr/local/bin/header-checker"

# Check if the application is already installed
if [ -f "$SCRIPT_PATH" ]; then
  echo "The header checker is already installed at $SCRIPT_PATH."
  echo "You can run it using the command: 'header-checker <url>'."
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
  echo "The command 'header-checker' is already available in your PATH."
else
  # Create a symlink in /usr/local/bin for easy access
  sudo ln -s "$SCRIPT_PATH" "$LINK_PATH"
  echo "Installation complete! You can now run the header checker using the command 'header-checker <url>'."
fi
