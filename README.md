# Context Optimizer & Token Saver 🧠🔋

AI coding agents (like Claude Code, Cline, Roo, and Gemini CLI) are incredibly powerful, but they often suffer from a critical flaw: **Context Bloat & Token Waste.**

When agents explore a large codebase, they tend to read entire files just to find a single line, dump huge search results into their memory, and loop over old mistakes. This bloats the context window, wastes tokens, and makes the AI slower and more expensive.

**Token Save Optimizer** is a CLI tool that enforces a "Search Diet" and a "Memory Refresh Protocol" across all your AI agents.

---

## ⚡ One-Time Global Install

Run this **once** on your machine. It installs the `tokensaveoptimizer` command globally:

```bash
curl -fsSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/main/install.sh | bash
```

---

## 🚀 Usage

Now in **any project**, just run:

```bash
tokensaveoptimizer install
```

This launches an interactive wizard that asks which AI tools you use, then automatically configures all of them!

```
======================================================
🚀 Welcome to Token Save Optimizer! 🧠🔋
======================================================
Which AI tools do you want to install this for?

  1) Claude Code (.claudecode)
  2) Cline (.clinerules)
  3) Roo Code (.roomodes)
  4) Kilo (.kilorules)
  5) Gemini CLI / Antigravity (.geminirules)
  6) Open Code (.opencode)
  7) 🎯 Install for ALL of them

Your selection: 1 3
```

You can select **multiple tools at once** or press `7` to install for all of them.

---

## 📊 Token Savings Statistics

Want to see exactly how many tokens the optimizer is saving you on the current project?

```bash
tokensaveoptimizer stats
```

Example output:
```
📊 Token Save Optimizer Statistics
======================================================
Raw Project Tokens (if AI read everything):  148,200
Optimized Repo Map Tokens:                     1,240
------------------------------------------------------
🔥 Total Tokens Saved per AI Exploration:   146,960 🔥
------------------------------------------------------
```

---

## 💡 How It Works

| Without Optimizer | With Optimizer |
|---|---|
| AI runs `ls -R` & reads whole files | AI reads a tiny compressed `.ai-memory/repo-map.txt` |
| AI forgets work and loops | AI writes milestones to `.ai-memory/state.md` |
| Token usage explodes | Context stays clean and focused |

Once installed, **you don't need to do anything**. The AI automatically reads the rules. But if you notice it looping, simply tell it:
> *"Please refresh your memory state."*

---

## 🤝 Compatibility

| Tool | Config File |
|---|---|
| Claude Code | `.claudecode` |
| Cline | `.clinerules` |
| Roo Code | `.roomodes` |
| Kilo | `.kilorules` |
| Gemini CLI | `.geminirules` |
| Open Code | `.opencode` |

---

## 📄 License

MIT License — free to use, modify, and distribute.
