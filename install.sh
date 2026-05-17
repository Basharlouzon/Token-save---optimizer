#!/bin/bash
# install.sh
# Installs the Tokenso CLI globally

echo "🚀 Installing Tokenso CLI..."

INSTALL_DIR="/usr/local/bin"
# Detect if $HOME/.local/bin exists and is writable
if [ -d "$HOME/.local/bin" ] && [ -w "$HOME/.local/bin" ]; then
    INSTALL_DIR="$HOME/.local/bin"
fi

CLI_URL="https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/bin/tokenso"

# Fallback to local testing if running locally
if [ -f "bin/tokenso" ]; then
    echo "Installing from local source..."
    if [ ! -w "$INSTALL_DIR" ]; then
        sudo cp bin/tokenso "$INSTALL_DIR/tokenso"
        sudo chmod +x "$INSTALL_DIR/tokenso"
    else
        cp bin/tokenso "$INSTALL_DIR/tokenso"
        chmod +x "$INSTALL_DIR/tokenso"
    fi
else
    echo "Downloading from GitHub..."
    if [ ! -w "$INSTALL_DIR" ]; then
        echo "Requires sudo privileges to install to $INSTALL_DIR"
        sudo curl -sSL "$CLI_URL" -o "$INSTALL_DIR/tokenso"
        sudo chmod +x "$INSTALL_DIR/tokenso"
    else
        curl -sSL "$CLI_URL" -o "$INSTALL_DIR/tokenso"
        chmod +x "$INSTALL_DIR/tokenso"
    fi
fi

echo "✅ Installed successfully!"
echo ""
echo "You can now run this command in ANY project:"
echo -e "\033[0;36m  tokenso\033[0m"
echo "or get started immediately with:"
echo -e "\033[0;36m  tokenso run\033[0m"
echo ""
