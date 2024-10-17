#!/bin/bash

# URL for the script in raw format
SCRIPT_URL="https://raw.githubusercontent.com/yousafkhamza/header-checker/main/check_headers.sh"

# Create the directory for the application
mkdir -p ~/header-checker

# Download the script
curl -sSL "$SCRIPT_URL" -o ~/header-checker/check_headers.sh

# Make the script executable
chmod +x ~/header-checker/check_headers.sh

# Create a symlink in /usr/local/bin for easy access
sudo ln -s ~/header-checker/check_headers.sh /usr/local/bin/header-checker

echo "Installation complete! You can now run the header checker using the command 'header-checker <url>'."
