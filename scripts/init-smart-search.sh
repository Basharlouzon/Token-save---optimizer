#!/bin/bash
# init-smart-search.sh
# Generates a highly compressed directory map to save AI token usage.

TARGET_DIR="${1:-.}"
MEMORY_DIR="$TARGET_DIR/.ai-memory"

echo "Initializing Tokenso smart search memory in $MEMORY_DIR..."

mkdir -p "$MEMORY_DIR"

# Create or touch the state file
if [ ! -f "$MEMORY_DIR/state.md" ]; then
  cat << 'EOF' > "$MEMORY_DIR/state.md"
# AI Memory State

## Completed Tasks
- [x] Initialized Tokenso smart search memory

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
  tree -I "node_modules|.git|build|dist|.dart_tool|ios/Pods|android/.gradle|.venv|venv|__pycache__|.idea|.vscode|.expo|.next|.nuxt|out|coverage|.nyc_output|target|.cargo|*.png|*.jpg|*.jpeg|*.gif|*.ico|*.pdf|*.zip|*.gz|*.tar|*.mp4|*.mp3|*.woff|*.woff2|*.ttf|*.eot|*.map|*.apk|*.ipa|*.bundle|package-lock.json|yarn.lock|pnpm-lock.yaml|bun.lockb" "$TARGET_DIR" > "$MEMORY_DIR/repo-map.txt"
else
  # Fallback if tree is not installed
  find "$TARGET_DIR" \
    -type d \( -name node_modules -o -name .git -o -name build -o -name dist -o -name .dart_tool -o -name Pods -o -name .gradle -o -name .venv -o -name venv -o -name __pycache__ -o -name .idea -o -name .vscode -o -name .expo -o -name .next -o -name .nuxt -o -name out -o -name coverage -o -name .nyc_output -o -name target -o -name .cargo \) -prune -o \
    -type f -not -name "*.png" -not -name "*.jpg" -not -name "*.jpeg" -not -name "*.gif" -not -name "*.ico" -not -name "*.pdf" -not -name "*.zip" -not -name "*.gz" -not -name "*.tar" -not -name "*.mp4" -not -name "*.mp3" -not -name "*.woff" -not -name "*.woff2" -not -name "*.ttf" -not -name "*.eot" -not -name "*.map" -not -name "*.apk" -not -name "*.ipa" -not -name "*.bundle" -not -name "package-lock.json" -not -name "yarn.lock" -not -name "pnpm-lock.yaml" -not -name "bun.lockb" -print > "$MEMORY_DIR/repo-map.txt"
fi

# Get token count estimate (rough estimate: words / 0.75)
WORDS=$(wc -w < "$MEMORY_DIR/repo-map.txt")
EST_TOKENS=$(( WORDS * 4 / 3 ))

echo "Done! The repository map is ready at $MEMORY_DIR/repo-map.txt (Estimated tokens: $EST_TOKENS)."
echo "Agents should read this file instead of manually exploring the workspace."

# Hook to update Tokenso stats silently
if [ -z "$TOKENSO_INTERNAL" ]; then
  if command -v tokenso &>/dev/null; then
    TOKENSO_INTERNAL=1 tokenso save --silent
  elif [ -f "./bin/tokenso" ]; then
    TOKENSO_INTERNAL=1 ./bin/tokenso save --silent
  elif [ -f "../bin/tokenso" ]; then
    TOKENSO_INTERNAL=1 ../bin/tokenso save --silent
  fi
fi
