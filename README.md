# Tokenso 🧠🔋

> Stop AI agents from wasting tokens, looping, and reading your entire codebase on every task.

AI coding agents are incredibly powerful, but they often suffer from a critical flaw: **Context Bloat & Token Waste.** When agents explore a large codebase, they read entire files just to find a single line, dump huge search results into memory, and loop over old mistakes — burning tokens and money.

**Tokenso** is a CLI tool that enforces a "Search Diet" and a "Memory Refresh Protocol" across **15+ AI tools** — from CLI agents to editors to enterprise platforms.

---

## ⚡ One-Time Global Install

Run this **once** on your machine. It installs the `tokenso` command globally:

```bash
curl -fsSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/install.sh | bash
```

---

## 🚀 Quick Start

To run the interactive cognitive mindmap search:

```bash
tokenso run
```

Or run the project setup wizard to configure rules for your editors/agents:

```bash
tokenso install
```

An interactive wizard launches — pick any tools you use:

```
── AI Coding Agents ──────────────────────────────
 1) Claude Code          (.claudecode + CLAUDE.md)
 2) Cline                (.clinerules)
 3) Roo Code             (.roomodes)
 4) Kilo                 (.kilorules)
 5) Gemini CLI           (.geminirules)
 6) Open Code            (.opencode)
 7) Aider                (.aider.conf.yml + CONVENTIONS.md)
 8) Continue.dev         (.continue/config.yaml)
16) ⭐ Antigravity         (global skill + .geminirules)
── AI-Powered Editors ────────────────────────────
 9) Cursor               (.cursorrules + .cursor/rules/)
10) Windsurf (Codeium)   (.windsurfrules)
11) Void Editor          (.voidrules)
12) Zed AI               (.zed/assistant-rules.md)
13) PearAI               (.pearai)
── Enterprise & Cloud ────────────────────────────
14) GitHub Copilot       (.github/copilot-instructions.md)
15) Amazon Q Developer   (.amazonq/rules/)
     0) 🎯 ALL of them

  Your selection: 1 9 14
```

Select **multiple tools** with space-separated numbers, or `0` for all.

---

## 🧠 Interactive Terminal Mindmap

When you run `tokenso run`, Tokenso visually maps the relationships and files in your workspace, fires "synapses" to link nodes together, prompts to save the optimized map, and launches the live stats dashboard:

```
  ████████╗ ██████╗ ██╗  ██╗███████╗███╗   ██╗ ██████╗ 
  ╚══██╔══╝██╔═══██╗██║ ██╔╝██╔════╝████╗  ██║██╔═══██╗
     ██║   ██║   ██║█████╔╝ █████╗  ██╔██╗ ██║██║   ██║
     ██║   ██║   ██║██╔═██╗ ██╔══╝  ██║╚██╗██║██║   ██║
     ██║   ╚██████╔╝██║  ██╗███████╗██║ ╚████║╚██████╔╝
     ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ 
           Cognitive Mindmap Search  v1.0.0

  🔍 Scanning project workspace for AI Mindmap nodes...
    ● Discovered [Workspace Code] ... Logic structures & codebase symbols
    ● Discovered [Context Rules] ... Agent constraints & optimization rules
    ● Discovered [Memory State] ... AI milestone journal & state tracker
    ● Discovered [Semantic Map] ... Optimized folder structures map

  ⚡ Firing cognitive synapses to connect nodes...
    Linked:  [Workspace Code] ══════════════════════════════> [Semantic Map]  ✔
    Linked:  [Context Rules] ══════════════════════════════> [Memory State]  ✔

  ✨ Cognitive Mindmap Successfully Integrated!
  Estimated savings vectors initialized at ~85% context compression.

  ┌────────────────────────────────────────────────────────┐
  │  ❓ Connect nodes and save Tokenso optimized map? [Y/n] │
  └────────────────────────────────────────────────────────┘
```

---

## 📊 Live Token Dashboard

Just type `tokenso` or `tokenso stats` in any initialized project to see your exact token savings:

```
📁 Project:  my-awesome-app
🤖 Active agents: Claude Code  Cursor  GitHub Copilot
──────────────────────────────────────────────────────
── THIS SESSION ─────────────────────────────────────
  Full scan (est. tokens):      148,200
  Optimized map tokens:           1,240
  Tokens saved:                 146,960  (~99%)
  Est. cost saved:              $0.4409

  Reduction: [████████████████████████████████████░░░]  99%

── ALL TIME ─────────────────────────────────────────
  Total AI sessions:            12
  Total tokens saved:           1,763,520
  Total cost saved (est.):      $5.29
```

---

## 💡 How It Works

| Without Tokenso | With Tokenso |
|---|---|
| AI runs `ls -R` & reads whole files | AI reads a tiny compressed `.ai-memory/repo-map.txt` |
| AI forgets work and loops | AI writes milestones to `.ai-memory/state.md` |
| Tokens explode every session | Context stays clean and cumulative savings grow |

Once installed, **you don't need to do anything**. The AI automatically reads the rules. But if you notice it looping, simply tell it:
> *"Please refresh your memory state."*

---

## 🛠 Commands

| Command | Description |
|---|---|
| `tokenso` | Live dashboard with stats |
| `tokenso run` | Interactive cognitive mindmap search & stats save |
| `tokenso install` | Interactive project setup wizard |
| `tokenso stats` | Detailed token report |
| `tokenso reset` | Clear cumulative stats |
| `tokenso update` | Self-update from GitHub |
| `tokenso --version` | Show version |

---

## 🤝 Compatibility

### AI Coding Agents
| Tool | Config File(s) |
|---|---|
| Claude Code | `.claudecode` + `CLAUDE.md` |
| Cline | `.clinerules` |
| Roo Code | `.roomodes` |
| Kilo | `.kilorules` |
| Gemini CLI | `.geminirules` |
| Open Code | `.opencode` |
| Aider | `CONVENTIONS.md` + `.aider.conf.yml` |
| Continue.dev | `.continue/config.yaml` |

### ⭐ Antigravity (Google DeepMind)
| What | Where |
|---|---|
| **Global skill** | `~/.gemini/antigravity/skills/context-optimizer/` |
| **Project rules** | `.geminirules` |

> Selecting option `16` installs a persistent global skill into Antigravity's skill directory so the optimizer is active in **every** project automatically — not just the current one.

### AI-Powered Editors
| Tool | Config File(s) |
|---|---|
| Cursor | `.cursorrules` + `.cursor/rules/token-optimizer.mdc` |
| Windsurf (Codeium) | `.windsurfrules` |
| Void Editor | `.voidrules` |
| Zed AI | `.zed/assistant-rules.md` |
| PearAI | `.pearai` |

### Enterprise & Cloud
| Tool | Config File(s) |
|---|---|
| GitHub Copilot | `.github/copilot-instructions.md` |
| Amazon Q Developer | `.amazonq/rules/token-optimizer.md` |

---

## 📄 License

MIT License — free to use, modify, and distribute.
