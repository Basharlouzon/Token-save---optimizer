# Context Optimizer & Token Saver 🧠🔋

AI coding agents (like Claude Code, Cline, Roo, and Antigravity) are incredibly powerful, but they often suffer from a critical flaw: **Context Bloat & Token Waste.**

When agents explore a large codebase, they tend to read entire files just to find a single line, dump huge search results into their memory, and loop over old mistakes. This bloats the context window, wastes tokens, and makes the AI slower and more expensive.

**Context Optimizer** is a set of rules and scripts designed to put your AI agent on a strict "Search Diet" and enforce a "Memory Refresh Protocol".

## 🚀 Quick Install (1-Liner)

The easiest way to install Context Optimizer into your current project is via your terminal. Run the following command at the root of your project:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO-NAME/main/install.sh | bash
```
*(Make sure to replace `YOUR-USERNAME/YOUR-REPO-NAME` with the actual GitHub path once published!)*

**What this does:**
1. Creates a local `.ai-memory/scripts/` folder.
2. Downloads the tiny `init-smart-search.sh` script.
3. Automatically injects the token-saving rules directly into `.clinerules`, `.roomodes`, and `.claudecode` if they exist (or creates them if they don't).

### Manual Install
If you prefer not to run scripts, you can manually copy and paste the block below into your AI's custom instructions file (e.g., `.clinerules`):

```markdown
# ==========================================
# CONTEXT OPTIMIZER & TOKEN SAVER RULES
# ==========================================
- **Search Diet**: Do not read full files blindly. Check file size first. Use lightweight search to find filenames before reading. Only read specific line ranges required.
- **Smart Init**: If you need to explore the project, do not run `ls -R`. Instead, run `bash .ai-memory/scripts/init-smart-search.sh .` and read `.ai-memory/repo-map.txt`.
- **Memory Protocol**: Before acting, always read `.ai-memory/state.md`. Upon reaching a milestone or repeating actions, compress your current understanding into `.ai-memory/state.md` and explicitly command yourself to forget the prior raw context to save tokens.
- **Stop Duplication**: If you find yourself in a loop or re-reading the same files, STOP. Update the memory state and ask the user for clarification.
```

## 🛠 Advanced Features

### 1. Smart Initialization Script
Included in this repo is `scripts/init-smart-search.sh`. 
When an AI agent runs this script, it generates a highly compressed map of your repository (excluding bulky directories like `node_modules` or `.git`) at `.ai-memory/repo-map.txt`. 

Instead of burning tokens on heavy `ls` or `find` commands, the agent can instantly read the tiny `repo-map.txt` to understand your project structure.

### 2. Auto-Injector Script
If you are starting a new project, you can have your AI agent run the `scripts/apply-cross-rules.sh` script. This will automatically inject the token-saving rules into your `.clinerules`, `.roomodes`, and `.claudecode` dotfiles.

## 🤝 Compatibility
This protocol is framework-agnostic and works with:
- Claude Code
- Cline
- Roo Code
- Kilo
- Antigravity

## 📄 License
This project is open-source under the MIT License. Feel free to use, modify, and distribute it!
