#!/bin/bash
# apply-cross-rules.sh
# Injects Tokenso context-optimizer rules into all supported AI agent config files.

TARGET_DIR="${1:-.}"

RULES=$(cat << 'EOF'

# ==========================================
# TOKENSO CONTEXT OPTIMIZER RULES
# ==========================================
- **Search Diet**: Do not read full files blindly. Check file size first. Use lightweight search to find filenames before reading. Only read specific line ranges required.
- **Smart Init**: If you need to explore the project, do not run `ls -R`. Instead, run `bash .ai-memory/scripts/init-smart-search.sh .` and read `.ai-memory/repo-map.txt`.
- **Memory Protocol**: Before acting, always read `.ai-memory/state.md`. Upon reaching a milestone or repeating actions, compress your current understanding into `.ai-memory/state.md` and explicitly command yourself to forget the prior raw context to save tokens.
- **Stop Duplication**: If you find yourself in a loop or re-reading the same files, STOP. Update the memory state and ask the user for clarification.
EOF
)

MARKER="TOKENSO CONTEXT OPTIMIZER RULES"

inject_rules() {
    local file=$1
    local name=$2
    local full_path="$TARGET_DIR/$file"
    local full_dir
    full_dir=$(dirname "$full_path")
    
    if [ -f "$full_path" ]; then
        if ! grep -q "$MARKER" "$full_path"; then
            echo "$RULES" >> "$full_path"
            echo "  ✅ Updated $name → $file"
        else
            echo "  ⚡ $name already configured."
        fi
    else
        mkdir -p "$full_dir"
        echo "$RULES" > "$full_path"
        echo "  ✅ Created $name → $file"
    fi
}

echo "Injecting Tokenso Context Optimizer rules into AI assistant configs in $TARGET_DIR..."

echo ""
echo "  AI Coding Agents:"
inject_rules ".claudecode"              "Claude Code"
inject_rules "CLAUDE.md"                "Claude Code (CLAUDE.md)"
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
