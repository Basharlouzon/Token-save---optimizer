#!/bin/bash
# install.sh
# Installs the Token Save Optimizer CLI globally

echo "🚀 Installing Token Save Optimizer CLI..."

INSTALL_DIR="/usr/local/bin"
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
echo -e "\033[0;36m  tokenso install\033[0m"
echo ""
