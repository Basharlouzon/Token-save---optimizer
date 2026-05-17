#!/bin/bash
# apply-cross-rules.sh
# Injects Tokenso context-optimizer rules into Cline, Roo, and Claude Code config files.

TARGET_DIR="${1:-.}"

RULES=$(cat << 'EOF'

# ==============================================================
# 🧠 TOKENSO — CONTEXT OPTIMIZER & ACTIVE MEMORY RULES
# ==============================================================
# These rules enforce maximum efficiency, preventing context window bloat 
# and stopping AI agents from repeating themselves or looping.

- **Zero-Waste Searching**: Do not read full files blindly. Check file size first. Use targeted searches (`grep_search`, `rg`) to locate file names, then read only specific line ranges.
- **Smart Mapping**: If you need to understand the project structure, do not run `ls -R` or `find`. Instead, execute `tokenso map` to visualize the lightweight, colorized tree hierarchy from `.ai-memory/repo-map.txt`.
- **Active Memory Protocol**: Before starting any task, read the current AI Memory using `tokenso state` (or checking `.ai-memory/state.md`). Upon reaching a milestone, fixing a bug, or taking complex steps, update the memory with `tokenso save "[Milestone Message]"` to compress findings.
- **Prune & Progress**: After saving state, explicitly offload previous raw context from your thinking. Focus only on the active checklist. If you detect that you are repeating failed commands or stuck in a loop, STOP, update the state, and ask the user for clarification.
EOF
)

echo "Injecting Tokenso Context Optimizer rules into AI assistant configs in $TARGET_DIR..."

# Inject into Cline
if [ -f "$TARGET_DIR/.clinerules" ]; then
  if ! grep -q "TOKENSO CONTEXT OPTIMIZER RULES" "$TARGET_DIR/.clinerules"; then
    echo "$RULES" >> "$TARGET_DIR/.clinerules"
    echo "Updated .clinerules"
  fi
else
  echo "$RULES" > "$TARGET_DIR/.clinerules"
  echo "Created .clinerules"
fi

# Inject into Roo
if [ -f "$TARGET_DIR/.roomodes" ]; then
  if ! grep -q "TOKENSO CONTEXT OPTIMIZER RULES" "$TARGET_DIR/.roomodes"; then
    echo "$RULES" >> "$TARGET_DIR/.roomodes"
    echo "Updated .roomodes"
  fi
else
  echo "$RULES" > "$TARGET_DIR/.roomodes"
  echo "Created .roomodes"
fi

# Inject into Claude Code
if [ -f "$TARGET_DIR/.claudecode" ]; then
  if ! grep -q "TOKENSO CONTEXT OPTIMIZER RULES" "$TARGET_DIR/.claudecode"; then
    echo "$RULES" >> "$TARGET_DIR/.claudecode"
    echo "Updated .claudecode"
  fi
else
  echo "$RULES" > "$TARGET_DIR/.claudecode"
  echo "Created .claudecode"
fi

echo "Tokenso cross-agent rules successfully applied."
