#!/bin/bash
# apply-cross-rules.sh
# Injects context-optimizer rules into Cline, Roo, and Claude Code config files.

TARGET_DIR="${1:-.}"

RULES=$(cat << 'EOF'

# ==========================================
# CONTEXT OPTIMIZER & TOKEN SAVER RULES
# ==========================================
- **Search Diet**: Do not read full files blindly. Check file size first. Use lightweight search to find filenames before reading. Only read specific line ranges required.
- **Smart Init**: If you need to explore the project, do not run `ls -R`. Instead, run `bash ~/.gemini/antigravity/skills/context-optimizer/scripts/init-smart-search.sh .` and read `.ai-memory/repo-map.txt`.
- **Memory Protocol**: Before acting, always read `.ai-memory/state.md`. Upon reaching a milestone or repeating actions, compress your current understanding into `.ai-memory/state.md` and explicitly command yourself to forget the prior raw context to save tokens.
- **Stop Duplication**: If you find yourself in a loop or re-reading the same files, STOP. Update the memory state and ask the user for clarification.
EOF
)

echo "Injecting Context Optimizer rules into AI assistant configs in $TARGET_DIR..."

# Inject into Cline
if [ -f "$TARGET_DIR/.clinerules" ]; then
  if ! grep -q "CONTEXT OPTIMIZER & TOKEN SAVER RULES" "$TARGET_DIR/.clinerules"; then
    echo "$RULES" >> "$TARGET_DIR/.clinerules"
    echo "Updated .clinerules"
  fi
else
  echo "$RULES" > "$TARGET_DIR/.clinerules"
  echo "Created .clinerules"
fi

# Inject into Roo
if [ -f "$TARGET_DIR/.roomodes" ]; then
  if ! grep -q "CONTEXT OPTIMIZER & TOKEN SAVER RULES" "$TARGET_DIR/.roomodes"; then
    echo "$RULES" >> "$TARGET_DIR/.roomodes"
    echo "Updated .roomodes"
  fi
else
  echo "$RULES" > "$TARGET_DIR/.roomodes"
  echo "Created .roomodes"
fi

# Inject into Claude Code
if [ -f "$TARGET_DIR/.claudecode" ]; then
  if ! grep -q "CONTEXT OPTIMIZER & TOKEN SAVER RULES" "$TARGET_DIR/.claudecode"; then
    echo "$RULES" >> "$TARGET_DIR/.claudecode"
    echo "Updated .claudecode"
  fi
else
  echo "$RULES" > "$TARGET_DIR/.claudecode"
  echo "Created .claudecode"
fi

echo "Cross-agent rules successfully applied."
