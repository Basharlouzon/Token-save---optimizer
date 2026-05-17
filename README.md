# Context Optimizer & Token Saver 🧠🔋

AI coding agents (like Claude Code, Cline, Roo, and Antigravity) are incredibly powerful, but they often suffer from a critical flaw: **Context Bloat & Token Waste.**

When agents explore a large codebase, they tend to read entire files just to find a single line, dump huge search results into their memory, and loop over old mistakes. This bloats the context window, wastes tokens, and makes the AI slower and more expensive.

**Context Optimizer** is a set of rules and scripts designed to put your AI agent on a strict "Search Diet" and enforce a "Memory Refresh Protocol".

## 🚀 Quick Install (1-Liner)

The easiest way to install Context Optimizer into your current project is via your terminal. Run the following command at the root of your project:

```bash
curl -fsSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/main/install.sh | bash
```

**What this does:**
1. Launches an **interactive wizard** in your terminal.
2. Asks you which AI tools you use (multi-select supported!).
3. Creates a local `.ai-memory/scripts/` folder and downloads the `init-smart-search.sh` script.
4. Automatically injects the token-saving rules directly into your selected tools' configuration files (e.g., `.clinerules`, `.roomodes`, `.claudecode`, `.geminirules`, etc.).

## 💡 How to Use

Once installed, **you don't have to do anything**. The AI agent will automatically follow the new rules.

However, if you notice your agent getting stuck in a loop or starting to waste tokens on a long task, you can explicitly prompt it:
> *"Please refresh your memory state."*

The agent will then pause, write a summary of its progress into `.ai-memory/state.md`, clear its bloated thought history, and resume working with a fresh, clean context!

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
