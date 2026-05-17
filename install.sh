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

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "\033[1;33m⚠️  Warning: $INSTALL_DIR is not in your active PATH.\033[0m"
    echo -e "To run \033[0;36mtokenso\033[0m globally, add it to your shell configuration:"
    echo ""
    current_shell=$(basename "$SHELL")
    if [ "$current_shell" = "zsh" ]; then
        echo -e "  \033[0;32mexport PATH=\"\$PATH:$INSTALL_DIR\"\033[0m"
    else
        echo -e "  \033[0;32mexport PATH=\"\$PATH:$INSTALL_DIR\"\033[0m"
    fi
    echo ""
else
    echo "You can now run this command in ANY project:"
    echo -e "\033[0;36m  tokenso\033[0m"
    echo "or get started immediately with:"
    echo -e "\033[0;36m  tokenso run\033[0m"
    echo ""

    # Prompt the user to initialize rule configurations in the current project
    if [ -t 0 ]; then
        read -p "Would you like to configure Tokenso memory rules in the current directory now? (y/N): " configure_now
        if [[ "$configure_now" =~ ^[yY](es)?$ ]]; then
            echo ""
            "$INSTALL_DIR/tokenso" install
        fi
    fi
fi
