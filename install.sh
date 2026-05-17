#!/bin/bash
# install.sh
# Installs Context Optimizer rules and scripts into the current project.

echo "🚀 Installing Context Optimizer..."

# Create local script directory to ensure the agent has access to it
mkdir -p .ai-memory/scripts

# Fetch the smart search script (Replace YOUR-USERNAME/YOUR-REPO-NAME with your actual GitHub info once published)
# For now, it will copy the local one if it exists, or try to fetch it online
if [ -f "scripts/init-smart-search.sh" ]; then
    cp scripts/init-smart-search.sh .ai-memory/scripts/init-smart-search.sh
else
    curl -sSL "https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO-NAME/main/scripts/init-smart-search.sh" -o .ai-memory/scripts/init-smart-search.sh
fi

chmod +x .ai-memory/scripts/init-smart-search.sh

# The rules block
RULES=$(cat << 'EOF'

# ==========================================
# CONTEXT OPTIMIZER & TOKEN SAVER RULES
# ==========================================
- **Search Diet**: Do not read full files blindly. Check file size first. Use lightweight search to find filenames before reading. Only read specific line ranges required.
- **Smart Init**: If you need to explore the project, do not run `ls -R`. Instead, run `bash .ai-memory/scripts/init-smart-search.sh .` and read `.ai-memory/repo-map.txt`.
- **Memory Protocol**: Before acting, always read `.ai-memory/state.md`. Upon reaching a milestone or repeating actions, compress your current understanding into `.ai-memory/state.md` and explicitly command yourself to forget the prior raw context to save tokens.
- **Stop Duplication**: If you find yourself in a loop or re-reading the same files, STOP. Update the memory state and ask the user for clarification.
EOF
)

# Inject into common agent dotfiles
for file in .clinerules .roomodes .claudecode; do
  if [ -f "$file" ]; then
    if ! grep -q "CONTEXT OPTIMIZER & TOKEN SAVER RULES" "$file"; then
      echo "$RULES" >> "$file"
      echo "✅ Updated $file"
    else
      echo "⚡ $file already has the rules applied."
    fi
  else
    echo "$RULES" > "$file"
    echo "✅ Created $file"
  fi
done

echo "🎉 Context Optimizer installed successfully in this project!"
echo "Agents will now use .ai-memory/scripts/init-smart-search.sh for exploration."
