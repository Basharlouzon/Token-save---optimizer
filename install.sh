#!/bin/bash
# install.sh
# Installs the Token Save Optimizer CLI globally

echo "🚀 Installing Token Save Optimizer CLI..."

INSTALL_DIR="/usr/local/bin"
CLI_URL="https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/bin/tokensaveoptimizer"

# Fallback to local testing if running locally
if [ -f "bin/tokensaveoptimizer" ]; then
    echo "Installing from local source..."
    if [ ! -w "$INSTALL_DIR" ]; then
        sudo cp bin/tokensaveoptimizer "$INSTALL_DIR/tokensaveoptimizer"
        sudo chmod +x "$INSTALL_DIR/tokensaveoptimizer"
    else
        cp bin/tokensaveoptimizer "$INSTALL_DIR/tokensaveoptimizer"
        chmod +x "$INSTALL_DIR/tokensaveoptimizer"
    fi
else
    echo "Downloading from GitHub..."
    if [ ! -w "$INSTALL_DIR" ]; then
        echo "Requires sudo privileges to install to $INSTALL_DIR"
        sudo curl -sSL "$CLI_URL" -o "$INSTALL_DIR/tokensaveoptimizer"
        sudo chmod +x "$INSTALL_DIR/tokensaveoptimizer"
    else
        curl -sSL "$CLI_URL" -o "$INSTALL_DIR/tokensaveoptimizer"
        chmod +x "$INSTALL_DIR/tokensaveoptimizer"
    fi
fi

echo "✅ Installed successfully!"
echo ""
echo "You can now run this command in ANY project:"
echo -e "\033[0;36m  tokensaveoptimizer install\033[0m"
echo ""
