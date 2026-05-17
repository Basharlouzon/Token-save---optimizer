#!/bin/bash
# install.sh — Global Installer for Tokenso CLI
# https://github.com/Basharlouzon/Token-save---optimizer

# ─── Colors ────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; BGREEN='\033[1;32m'
BLUE='\033[0;34m';  BBLUE='\033[1;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m';  BCYAN='\033[1;36m'
RED='\033[0;31m';   BRED='\033[1;31m'
BOLD='\033[1m';     DIM='\033[2m'
NC='\033[0m'

# ─── ASCII Banner ──────────────────────────────────────────────────────────
clear
echo -e "${BBLUE}"
echo "  ████████╗ ██████╗ ██╗  ██╗███████╗███╗   ██╗ ██████╗ "
echo "  ╚══██╔══╝██╔═══██╗██║ ██╔╝██╔════╝████╗  ██║██╔═══██╗"
echo "     ██║   ██║   ██║█████╔╝ █████╗  ██╔██╗ ██║██║   ██║"
echo "     ██║   ██║   ██║██╔═██╗ ██╔══╝  ██║╚██╗██║██║   ██║"
echo "     ██║   ╚██████╔╝██║  ██╗███████╗██║ ╚████║╚██████╔╝"
echo "     ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ "
echo -e "${NC}${DIM}               Save Optimizer Global Installer${NC}"
echo ""

# ─── Helper Functions ──────────────────────────────────────────────────────
step_start() {
    echo -e "  ${YELLOW}○${NC}  $1..."
}

step_done() {
    # Move cursor up 1 line and clear it to render checked state
    printf "\033[1A\033[K"
    echo -e "  ${GREEN}✓${NC}  $1"
}

step_failed() {
    printf "\033[1A\033[K"
    echo -e "  ${RED}✗${NC}  ${RED}Failed: $1${NC}"
}

# ─── 1. System Environment Scan ───────────────────────────────────────────
step_start "Detecting system configuration"
sleep 0.3
current_shell=$(basename "$SHELL")
step_done "Detected system configuration (Shell: ${CYAN}$current_shell${NC})"

# ─── 2. Determine Target Directory ───────────────────────────────────────
step_start "Locating target installation path"
sleep 0.2
INSTALL_DIR="/usr/local/bin"
if [ -d "$HOME/.local/bin" ] && [ -w "$HOME/.local/bin" ]; then
    INSTALL_DIR="$HOME/.local/bin"
fi
step_done "Locating target installation path (Target: ${CYAN}$INSTALL_DIR${NC})"

# ─── 3. Copy Executable Files ─────────────────────────────────────────────
step_start "Copying Tokenso executable to target"
sleep 0.4
CLI_URL="https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/bin/tokenso"

if [ -f "bin/tokenso" ]; then
    if [ ! -w "$INSTALL_DIR" ]; then
        sudo cp bin/tokenso "$INSTALL_DIR/tokenso"
        sudo chmod +x "$INSTALL_DIR/tokenso"
    else
        cp bin/tokenso "$INSTALL_DIR/tokenso"
        chmod +x "$INSTALL_DIR/tokenso"
    fi
    step_done "Copied Tokenso executable from local source successfully!"
else
    if [ ! -w "$INSTALL_DIR" ]; then
        echo -e "  ${YELLOW}🔑 Sudo privileges required to install to $INSTALL_DIR...${NC}"
        sudo curl -sSL "$CLI_URL" -o "$INSTALL_DIR/tokenso"
        sudo chmod +x "$INSTALL_DIR/tokenso"
    else
        curl -sSL "$CLI_URL" -o "$INSTALL_DIR/tokenso"
        chmod +x "$INSTALL_DIR/tokenso"
    fi
    step_done "Downloaded & installed Tokenso CLI globally successfully!"
fi

# ─── 4. PATH Registration and Shell Profile Detection ────────────────────
step_start "Scanning shell profile configuration"
sleep 0.3

PROFILE=""
if [ "$current_shell" = "zsh" ] && [ -f "$HOME/.zshrc" ]; then
    PROFILE="$HOME/.zshrc"
elif [ "$current_shell" = "bash" ]; then
    if [ -f "$HOME/.bash_profile" ]; then
        PROFILE="$HOME/.bash_profile"
    elif [ -f "$HOME/.bashrc" ]; then
        PROFILE="$HOME/.bashrc"
    fi
fi
[ -z "$PROFILE" ] && [ -f "$HOME/.profile" ] && PROFILE="$HOME/.profile"
[ -z "$PROFILE" ] && PROFILE="$HOME/.zshrc" # Default fallback

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    step_done "Shell profile scanned (${YELLOW}PATH insertion needed${NC})"
    echo ""
    echo -e "  ${YELLOW}⚠️  Warning: $INSTALL_DIR is not in your current PATH.${NC}"
    
    if [ -t 0 ]; then
        read -p "  Would you like to automatically append it to your $PROFILE? [Y/n]: " path_choice
        if [[ ! "$path_choice" =~ ^[Nn]$ ]]; then
            echo "" >> "$PROFILE"
            echo "# Tokenso CLI PATH configuration" >> "$PROFILE"
            echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$PROFILE"
            echo -e "  ${GREEN}✓ Shell profile ($PROFILE) updated successfully!${NC}"
            echo -e "  ${YELLOW}💡 Please run 'source $PROFILE' or restart terminal to load the global path.${NC}"
        else
            echo -e "  ${DIM}Skipped profile configuration.${NC}"
        fi
    else
        echo -e "  To run tokenso globally, manually add this to your shell profile:"
        echo -e "    ${CYAN}export PATH=\"\$PATH:$INSTALL_DIR\"${NC}"
    fi
else
    step_done "Shell profile scanned (PATH matches ${GREEN}OK${NC})"
    echo ""
    echo -e "  ${BGREEN}✨ Tokenso global command is fully active!${NC}"
    echo -e "  You can run ${CYAN}tokenso${NC} or ${CYAN}tokenso run${NC} directly from any repository workspace."
    echo ""
fi

# ─── 5. Immediate Local Setup Onboarding ──────────────────────────────────
if [ -t 0 ]; then
    read -p "  Would you like to configure Tokenso AI memory in the current workspace now? [y/N]: " configure_now
    if [[ "$configure_now" =~ ^[yY](es)?$ ]]; then
        echo ""
        "$INSTALL_DIR/tokenso" install
    fi
fi

echo ""
echo -e "${BBLUE}======================================================${NC}"
echo -e "${BGREEN}🎉 Installation Completed!${NC}"
echo -e "  Star the repo ⭐  ${DIM}github.com/Basharlouzon/Token-save---optimizer${NC}"
echo -e "${BBLUE}======================================================${NC}\n"
