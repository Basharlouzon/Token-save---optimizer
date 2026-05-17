#!/bin/bash
# init-smart-search.sh
# Generates a highly compressed directory map to save AI token usage.

TARGET_DIR="${1:-.}"
MEMORY_DIR="$TARGET_DIR/.ai-memory"

echo "Initializing smart search memory in $MEMORY_DIR..."

mkdir -p "$MEMORY_DIR"

# Create or touch the state file
if [ ! -f "$MEMORY_DIR/state.md" ]; then
  cat << 'EOF' > "$MEMORY_DIR/state.md"
# AI Memory State

## Completed Tasks
- [x] Initialized smart search memory

## Next Actions
- [ ] 

## Key Context & Architecture
- (Add crucial project facts here to avoid re-reading files)

EOF
  echo "Created initial state.md"
fi

# Generate the compressed repository map
# We exclude common large directories to keep token counts extremely low.
echo "Generating repo-map.txt..."

if command -v tree &> /dev/null; then
  tree -I "node_modules|.git|build|dist|.dart_tool|ios/Pods|android/.gradle|.venv|venv|__pycache__" "$TARGET_DIR" > "$MEMORY_DIR/repo-map.txt"
else
  # Fallback if tree is not installed
  find "$TARGET_DIR" -type d \( -name node_modules -o -name .git -o -name build -o -name dist -o -name .dart_tool -o -name Pods -o -name .gradle -o -name .venv -o -name venv -o -name __pycache__ \) -prune -o -print > "$MEMORY_DIR/repo-map.txt"
fi

# Get token count estimate (rough estimate: words / 0.75)
WORDS=$(wc -w < "$MEMORY_DIR/repo-map.txt")
EST_TOKENS=$(( WORDS * 4 / 3 ))

echo "Done! The repository map is ready at $MEMORY_DIR/repo-map.txt (Estimated tokens: $EST_TOKENS)."
echo "Agents should read this file instead of manually exploring the workspace."
