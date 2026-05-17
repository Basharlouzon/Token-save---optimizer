#!/bin/bash
# install.sh — Global Installer for Tokenso CLI
# https://github.com/Basharlouzon/Token-save---optimizer

set -eo pipefail

# Single source for cleanup + error reporting. Don't replace this trap later.
# `cleanup` must always exit 0 — a non-zero return from an EXIT trap can
# re-trigger ERR and print a spurious failure message after a clean run.
_TMP_CLI=""
cleanup() { [ -n "$_TMP_CLI" ] && rm -f "$_TMP_CLI"; return 0; }
on_err() { echo "Tokenso install failed at line $1" >&2; cleanup; exit 1; }
trap 'on_err $LINENO' ERR
trap 'cleanup' EXIT

# ─── Argument Parsing ──────────────────────────────────────────────────────
UNATTENDED=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes)
            UNATTENDED=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# ─── Acquire controlling TTY for piped installs (curl | bash). ─────────────
# If /dev/tty isn't usable (CI, certain IDE terminals, headless containers),
# force unattended mode rather than dying on the redirect or hanging later
# on a read prompt whose stdin has already been consumed by curl. The
# subshell probe avoids bash's own "Device not configured" diagnostic
# leaking to stderr from a direct exec.
if [ ! -t 0 ]; then
    if ( exec < /dev/tty ) 2>/dev/null; then
        exec < /dev/tty
    else
        echo "  ⚠️  No controlling terminal available — running in unattended mode." >&2
        UNATTENDED=true
    fi
fi

# ─── Colors ────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; BGREEN='\033[1;32m'
BLUE='\033[0;34m';  BBLUE='\033[1;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m';  BCYAN='\033[1;36m'
RED='\033[0;31m';   BRED='\033[1;31m'
BOLD='\033[1m';     DIM='\033[2m'
NC='\033[0m'

# ─── ASCII Banner ──────────────────────────────────────────────────────────
if [ "$UNATTENDED" = false ]; then
    clear >&2
    echo -e "${BBLUE}" >&2
    echo "  ████████╗ ██████╗ ██╗  ██╗███████╗███╗   ██╗ ██████╗ " >&2
    echo "  ╚══██╔══╝██╔═══██╗██║ ██╔╝██╔════╝████╗  ██║██╔═══██╗" >&2
    echo "     ██║   ██║   ██║█████╔╝ █████╗  ██╔██╗ ██║██║   ██║" >&2
    echo "     ██║   ██║   ██║██╔═██╗ ██╔══╝  ██║╚██╗██║██║   ██║" >&2
    echo "     ██║   ╚██████╔╝██║  ██╗███████╗██║ ╚████║╚██████╔╝" >&2
    echo "     ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ " >&2
    echo -e "${NC}${DIM}               Save Optimizer Global Installer${NC}" >&2
    echo "" >&2
fi

# ─── Helper Functions ──────────────────────────────────────────────────────
step_start() {
    echo -e "  ${YELLOW}○${NC}  $1..." >&2
}

step_done() {
    printf "\033[1A\033[K" >&2
    echo -e "  ${GREEN}✓${NC}  $1" >&2
}

step_failed() {
    printf "\033[1A\033[K" >&2
    echo -e "  ${RED}✗${NC}  ${RED}Failed: $1${NC}" >&2
}

# ─── 1. System Environment Scan ───────────────────────────────────────────
step_start "Detecting system configuration"
current_shell=$(basename "$SHELL")
step_done "Detected system configuration (Shell: ${CYAN}$current_shell${NC})"

# ─── 2. Determine Target Directory ───────────────────────────────────────
step_start "Locating target installation path"
INSTALL_DIR="/usr/local/bin"
if [ -d "$HOME/.local/bin" ] && [ -w "$HOME/.local/bin" ]; then
    INSTALL_DIR="$HOME/.local/bin"
fi
# Validate target is reachable (writable directly OR via sudo).
if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR" 2>/dev/null || sudo mkdir -p "$INSTALL_DIR" \
        || { step_failed "Cannot create $INSTALL_DIR"; exit 1; }
fi
if [ ! -w "$INSTALL_DIR" ] && ! sudo -n true 2>/dev/null && [ "$UNATTENDED" = true ]; then
    step_failed "$INSTALL_DIR not writable and sudo unavailable in unattended mode"
    exit 1
fi
step_done "Locating target installation path (Target: ${CYAN}$INSTALL_DIR${NC})"

# ─── 3. Copy Executable Files ─────────────────────────────────────────────
step_start "Copying Tokenso executable to target"
CLI_URL="https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/bin/tokenso"

install_cli_from() {
    # Atomically install $1 to $INSTALL_DIR/tokenso, using sudo if needed.
    local src=$1
    if [ ! -s "$src" ]; then
        step_failed "Source CLI is empty or missing: $src"
        return 1
    fi
    if ! head -1 "$src" | grep -q '^#!'; then
        step_failed "Source CLI does not begin with a shebang (corrupt download?): $src"
        return 1
    fi
    if [ ! -w "$INSTALL_DIR" ]; then
        # Make the sudo prompt obvious — otherwise the user sees the "○" step
        # spinner above and assumes the script is hung when sudo silently waits
        # for a password.
        echo "" >&2
        echo -e "  ${BOLD}🔐 Your sudo password is required to install to $INSTALL_DIR:${NC}" >&2
        sudo install -m 0755 "$src" "$INSTALL_DIR/tokenso"
    else
        install -m 0755 "$src" "$INSTALL_DIR/tokenso"
    fi
}

if [ -f "bin/tokenso" ]; then
    install_cli_from "bin/tokenso"
    step_done "Copied Tokenso executable from local source successfully!"
else
    _TMP_CLI=$(mktemp -t tokenso.XXXXXX)
    # `-fsSL` is silent by design; a missing timeout means an unhealthy CDN or
    # slow link can hang for minutes with zero output, which looks like the
    # script is dead. Bound it.
    if ! curl -fsSL --connect-timeout 10 --max-time 120 "$CLI_URL" -o "$_TMP_CLI"; then
        step_failed "Download failed from $CLI_URL (connect or transfer timed out)"
        exit 1
    fi
    install_cli_from "$_TMP_CLI"
    step_done "Downloaded & installed Tokenso CLI globally successfully!"
fi

# ─── 4. Generate Shell Autocomplete Script ─────────────────────────────────
step_start "Installing shell autocomplete support"
cat << 'EOF' > "$HOME/.tokenso_completion.sh"
# ─── Tokenso CLI Autocomplete Completion ────────────────────────────────────

# Zsh Completion
if [ -n "$ZSH_VERSION" ]; then
    _tokenso_zsh_autocomplete() {
        local -a cmds
        cmds=(
            'run:Launch interactive GUI mindmap'
            'install:Configure local workspace AI memory'
            'save:Save and update tokens and repository map'
            'search:Zero-waste code search snippet utility'
            'stats:Display token optimizer stats and savings'
            'state:Display current AI memory state.md'
            'map:Show compressed codebase repository map'
            'clean:Clean temporary and cached optimizer files'
            'reset:Completely reset Tokenso files in repository'
            'update:Check and pull the latest CLI update'
            'help:Display help documentation'
        )
        
        _arguments -C \
            '1: :->cmds' \
            '*:: :->args'

        case "$state" in
            cmds)
                _describe -t commands "tokenso command" cmds
                ;;
            args)
                case $words[2] in
                    stats)
                        _arguments '--html[Generate premium glassmorphic visual HTML dashboard]'
                        ;;
                    save)
                        _arguments \
                            '(-s --silent)'{-s,--silent}'[Execute silently without terminal logging]' \
                            '(-m --message)'{-m,--message}'[Append a milestone note description]'
                        ;;
                esac
                ;;
        esac
    }
    if type compdef &>/dev/null; then
        compdef _tokenso_zsh_autocomplete tokenso
    fi
fi

# Bash Completion
if [ -n "$BASH_VERSION" ]; then
    _tokenso_bash_autocomplete() {
        local cur prev opts
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        opts="run install save search stats state map clean reset update help"

        if [[ ${COMP_CWORD} -eq 1 ]]; then
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
        fi

        case "${prev}" in
            stats)
                COMPREPLY=( $(compgen -W "--html" -- ${cur}) )
                return 0
                ;;
            save)
                COMPREPLY=( $(compgen -W "--silent -s --message -m" -- ${cur}) )
                return 0
                ;;
        esac
    }
    complete -F _tokenso_bash_autocomplete tokenso
fi
EOF
chmod +x "$HOME/.tokenso_completion.sh"
step_done "Installed shell autocomplete support to ~/.tokenso_completion.sh"

# ─── 5. PATH Registration and Shell Profile Detection ────────────────────
step_start "Scanning shell profile configuration"

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
[ -z "$PROFILE" ] && PROFILE="$HOME/.zshrc"

# Idempotent appends — bracketed by unique markers so re-running this installer
# never duplicates lines in the user's shell profile.
TOKENSO_PATH_BEGIN="# >>> tokenso path >>>"
TOKENSO_PATH_END="# <<< tokenso path <<<"
TOKENSO_COMP_BEGIN="# >>> tokenso completion >>>"
TOKENSO_COMP_END="# <<< tokenso completion <<<"

append_block_once() {
    # append_block_once <file> <begin-marker> <end-marker> <body...>
    local file=$1 begin=$2 end=$3
    shift 3
    [ -f "$file" ] || touch "$file"
    if grep -qF "$begin" "$file" 2>/dev/null; then
        return 1   # already present
    fi
    {
        echo ""
        echo "$begin"
        printf '%s\n' "$@"
        echo "$end"
    } >> "$file"
    return 0
}

write_path_block() {
    if append_block_once "$PROFILE" "$TOKENSO_PATH_BEGIN" "$TOKENSO_PATH_END" \
        "# Tokenso CLI PATH configuration" \
        "export PATH=\"\$PATH:$INSTALL_DIR\""; then
        return 0
    fi
    return 1
}

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    step_done "Shell profile scanned (${YELLOW}PATH insertion needed${NC})"
    echo "" >&2
    if [ "$UNATTENDED" = false ]; then
        echo -e "  ${YELLOW}⚠️  Warning: $INSTALL_DIR is not in your current PATH.${NC}" >&2
    fi

    if [ "$UNATTENDED" = true ]; then
        if write_path_block; then
            echo -e "  ${GREEN}✓ Shell profile ($PROFILE) automatically updated (unattended)!${NC}" >&2
        else
            echo -e "  ${DIM}Tokenso PATH block already present in $PROFILE — skipped.${NC}" >&2
        fi
    else
        read -p "  Would you like to automatically append it to your $PROFILE? [Y/n]: " path_choice
        if [[ ! "$path_choice" =~ ^[Nn]$ ]]; then
            if write_path_block; then
                echo -e "  ${GREEN}✓ Shell profile ($PROFILE) updated successfully!${NC}" >&2
                echo -e "  ${YELLOW}💡 Please run 'source $PROFILE' or restart terminal to load the global path.${NC}" >&2
            else
                echo -e "  ${DIM}Tokenso PATH block already present — skipped.${NC}" >&2
            fi
        else
            echo -e "  ${DIM}Skipped profile configuration.${NC}" >&2
        fi
    fi
else
    step_done "Shell profile scanned (PATH matches ${GREEN}OK${NC})"
    if [ "$UNATTENDED" = false ]; then
        echo "" >&2
        echo -e "  ${BGREEN}✨ Tokenso global command is fully active!${NC}" >&2
        echo -e "  You can run ${CYAN}tokenso${NC} or ${CYAN}tokenso run${NC} directly from any repository workspace." >&2
        echo "" >&2
    fi
fi

# Append autocomplete sourcing — idempotent via markers.
if append_block_once "$PROFILE" "$TOKENSO_COMP_BEGIN" "$TOKENSO_COMP_END" \
    "# Tokenso CLI completion configuration" \
    "[ -f \"\$HOME/.tokenso_completion.sh\" ] && source \"\$HOME/.tokenso_completion.sh\""; then
    if [ "$UNATTENDED" = false ]; then
        echo -e "  ${GREEN}✓ Shell autocomplete configuration appended to $PROFILE.${NC}" >&2
    fi
fi

# ─── 6. Immediate Local Setup Onboarding ──────────────────────────────────
if [ "$UNATTENDED" = false ]; then
    # Only offer in-workspace setup if the binary is invokable from PATH or
    # via the absolute path we just wrote — otherwise tell the user how to
    # activate it instead of running a command that will fail.
    if command -v tokenso &>/dev/null || [ -x "$INSTALL_DIR/tokenso" ]; then
        read -p "  Would you like to configure Tokenso AI memory in the current workspace now? [y/N]: " configure_now
        if [[ "$configure_now" =~ ^[yY](es)?$ ]]; then
            echo "" >&2
            "$INSTALL_DIR/tokenso" install
        fi
    else
        echo -e "  ${YELLOW}💡 Open a new shell or run 'source $PROFILE', then run 'tokenso install' inside your project.${NC}" >&2
    fi
fi

if [ "$UNATTENDED" = false ]; then
    echo "" >&2
    echo -e "${BBLUE}======================================================${NC}" >&2
    echo -e "${BGREEN}🎉 Installation Completed!${NC}" >&2
    echo -e "  Star the repo ⭐  ${DIM}github.com/Basharlouzon/Token-save---optimizer${NC}" >&2
    echo -e "${BBLUE}======================================================${NC}\n" >&2
fi
