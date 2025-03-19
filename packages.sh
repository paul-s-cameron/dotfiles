#!/bin/bash

# Ensure yay is installed
if ! command -v yay &> /dev/null; then
    echo "yay is not installed. Please install it first."
    exit 1
fi

# Check if the package list file exists
PACKAGE_FILE="$HOME/.dotfiles/.packages"
if [ ! -f "$PACKAGE_FILE" ]; then
    echo "Package list file not found: $PACKAGE_FILE"
    exit 1
fi

# Install packages from the list
yay -S --needed --noconfirm - < "$PACKAGE_FILE"

