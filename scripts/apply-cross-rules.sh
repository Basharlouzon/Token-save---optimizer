#!/bin/bash
# apply-cross-rules.sh
# Injects Tokenso context-optimizer rules into all supported AI agent config files.

set -euo pipefail

TARGET_DIR="${1:-.}"

# Bump this suffix whenever the rules text changes so updated rules re-apply
# cleanly on existing checkouts instead of being skipped as "already present".
MARKER_VERSION="v1"

RULES=$(cat << EOF

# ==========================================
# TOKENSO CONTEXT OPTIMIZER RULES ($MARKER_VERSION)
# ==========================================
- **Search Diet**: Do not read full files blindly. Check file size first. Use lightweight search to find filenames before reading. Only read specific line ranges required.
- **Smart Init**: If you need to explore the project, do not run \`ls -R\`. Instead, run \`tokenso map\` (or \`bash .ai-memory/scripts/init-smart-search.sh .\`) and read \`.ai-memory/repo-map.txt\`.
- **Memory Protocol**: Before acting, always read \`.ai-memory/state.md\`. Upon reaching a milestone or repeating actions, compress your current understanding into \`.ai-memory/state.md\` and explicitly command yourself to forget the prior raw context to save tokens.
- **Stop Duplication**: If you find yourself in a loop or re-reading the same files, STOP. Update the memory state and ask the user for clarification.
EOF
)

# Marker is version-aware so bumping MARKER_VERSION re-applies rules cleanly.
MARKER="TOKENSO CONTEXT OPTIMIZER RULES ($MARKER_VERSION)"

inject_rules() {
    local file=$1
    local name=$2
    local full_path="$TARGET_DIR/$file"
    local full_dir
    full_dir=$(dirname "$full_path")

    if [ -f "$full_path" ]; then
        if ! grep -qF "$MARKER" "$full_path"; then
            echo "$RULES" >> "$full_path"
            echo "  ✅ Updated $name → $file"
        else
            echo "  ⚡ $name already configured."
        fi
    else
        mkdir -p "$full_dir" || { echo "  ❌ Failed to create $full_dir" >&2; return 1; }
        echo "$RULES" > "$full_path"
        echo "  ✅ Created $name → $file"
    fi
}

echo "Injecting Tokenso Context Optimizer rules into AI assistant configs in $TARGET_DIR..."

echo ""
echo "  AI Coding Agents:"
inject_rules ".claudecode"              "Claude Code"
inject_rules "CLAUDE.md"                "Claude Code (CLAUDE.md)"
if [ ! -f "$TARGET_DIR/.claude/skills/brainstorming/SKILL.md" ]; then
    mkdir -p "$TARGET_DIR/.claude/skills/brainstorming"
    _BSRC=""
    [ -f "skills/brainstorming/SKILL.md" ] && _BSRC="skills/brainstorming/SKILL.md"
    [ -f ".claude/skills/brainstorming/SKILL.md" ] && _BSRC=".claude/skills/brainstorming/SKILL.md"
    if [ -n "$_BSRC" ]; then
        cp "$_BSRC" "$TARGET_DIR/.claude/skills/brainstorming/SKILL.md"
    else
        curl -sSL "https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/.claude/skills/brainstorming/SKILL.md" \
             -o "$TARGET_DIR/.claude/skills/brainstorming/SKILL.md" 2>/dev/null || true
    fi
    if [ -f "$TARGET_DIR/.claude/skills/brainstorming/SKILL.md" ]; then
        echo "  ✅ Installed brainstorming skill → .claude/skills/brainstorming/SKILL.md"
    fi
fi
inject_rules ".clinerules"              "Cline"
inject_rules ".roomodes"                "Roo Code"
inject_rules ".kilorules"               "Kilo"
inject_rules ".geminirules"             "Gemini CLI / Antigravity"
inject_rules ".opencode"                "Open Code"
inject_rules "CONVENTIONS.md"           "Aider (CONVENTIONS.md)"
inject_rules ".continue/config.yaml"    "Continue.dev"

echo ""
echo "  AI-Powered Editors:"
inject_rules ".cursorrules"                   "Cursor"
inject_rules ".cursor/rules/token-optimizer.mdc" "Cursor (rules/)"
inject_rules ".windsurfrules"                 "Windsurf"
inject_rules ".voidrules"                     "Void Editor"
inject_rules ".zed/assistant-rules.md"        "Zed AI"
inject_rules ".pearai"                        "PearAI"

echo ""
echo "  Enterprise & Cloud:"
inject_rules ".github/copilot-instructions.md"  "GitHub Copilot"
inject_rules ".amazonq/rules/token-optimizer.md" "Amazon Q Developer"

echo ""
echo "Tokenso cross-agent rules successfully applied."
