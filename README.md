<div align="center">

# 🧠🔋 Tokenso

### _Stop AI agents from wasting tokens, looping, and reading your entire codebase._

[![Version](https://img.shields.io/badge/v3.11.0-00bcd4?style=for-the-badge&logo=checkmark&label=version)](https://github.com/Basharlouzon/Token-save---optimizer)
[![License](https://img.shields.io/badge/MIT-00e676?style=for-the-badge&label=license)](LICENSE)
[![Shell](https://img.shields.io/badge/pure%20bash-100%25-4a90d9?style=for-the-badge&logo=gnubash&logoColor=white)]()
[![AI Tools](https://img.shields.io/badge/compatible-16%2B-ff6b6b?style=for-the-badge&logo=ai&label=AI%20tools)]()
[![Savings](https://img.shields.io/badge/avg_savings-99%25-00e676?style=for-the-badge&label=context%20reduction)]()

<br />

**One install. 16+ AI tools. Zero token waste.**

Tokenso puts your AI coding agents on a strict search diet with a persistent memory protocol. Every session, it tracks exactly how many tokens and dollars you saved — with a live terminal dashboard and a premium HTML export with interactive charts.

<br />

[🚀 Install](#-install) · [💡 How It Works](#-how-it-works) · [📊 Dashboard](#-dashboard--stats) · [🧠 Mindmap](#-interactive-mindmap) · [🔧 Commands](#-commands) · [🤝 Compatibility](#-compatibility)

<br />

</div>

---

## 🆕 What's New in 3.11.0

> **Command polish** — the help screen is now grouped by purpose, with focused per-command help and `tokenso claude` subcommands

| Feature                       | Description                                                                                                         |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------|
| 🗂️ **Grouped help**           | Commands organized into Setup & Memory, Explore & Search, Claude Code, Stats & Reports, Maintenance                |
| 📖 **`tokenso help <cmd>`**   | Focused usage + examples for a single command                                                                      |
| 🤖 **`tokenso claude` subs**  | `claude pause` / `claude resume` / `claude budget` group the plan-usage controls; top-level aliases still work     |

### v3.10.0 — `tk run` Claude Code Cockpit

> The cognitive mindmap surfaces your live integration state (hooks/pause/budget) and tells you what to do next

| Feature                       | Description                                                                                                       |
| ----------------------------- | -----------------------------------------------------------------------------------------------------------------|
| 🤖 **Integration panel**      | `tk run` shows hooks ✓/✗, pause ▶/⏸, and budget 🎯/○ status at a glance                                          |
| 🧭 **Actionable hints**       | Not installed? Paused? The panel prints the exact command to fix it (`tokenso claude install` / `resume`)         |
| 🕸️ **7th cognitive node**     | A new "Claude Code" node joins the scan + synapse animation, wired to Tokenso Core                                |

### v3.9.0 — Token Budget Gate

> `tokenso budget 100k` caps estimated reads per session and auto-pauses the project when you hit the ceiling ([ADR-0010](docs/adr/0010-budget-gate.md))

| Feature                   | Description                                                                                                                  |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------------------|
| 🎯 **`tokenso budget N`** | Per-session token cap (`100k` / `1.5m` / `100000`); resets each Claude Code session                                        |
| 🛑 **Auto-pause on cross**| At 100% the project hard-pauses (reuses the zero-cost gate); `tokenso resume` or `tokenso budget <bigger>` lifts it         |
| ⚠ **80% warn band**       | Statusline turns amber `⚠ tokenso ⏐ budget 87k/100k` before the freeze — no surprise cliff                                  |
| 🧮 **Honest estimate**    | Tallies guarded-read bytes only, labeled as an estimate (per [ADR-0005](docs/adr/0005-honest-telemetry.md)) — never faked   |
| 🔌 **No new hooks**       | Folded into the existing read-guard; `tokenso claude install` already wires it                                              |

### v3.8.0 — Pause Switch

> `tokenso pause` hard-blocks ALL Claude Code usage in a project (zero token burn) until you run `tokenso resume` ([ADR-0009](docs/adr/0009-pause-switch.md))

| Feature                  | Description                                                                                                                     |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------|
| ⏸ **`tokenso pause`**    | Drops a flag that blocks every prompt and tool call via hooks — protects your plan quota; optional reason: `tokenso pause "saving quota"` |
| ▶ **`tokenso resume`**   | One command lifts the block and Claude Code works again                                                                         |
| 🚪 **Prompt-level gate** | `UserPromptSubmit` hook blocks *before* the model is invoked — paused sessions cost **zero** tokens                            |
| 🧱 **Catch-all gate**    | `PreToolUse` matcher `*` stops in-flight sessions mid-turn too                                                                  |
| 📟 **Visible state**     | Statusline shows `⏸ tokenso PAUSED`; `tokenso claude status` shows pause + active hooks                                        |

### v3.7.0 — Native Claude Code Integration

> Tokenso savings are *enforced by the harness*, not just suggested in CLAUDE.md ([ADR-0008](docs/adr/0008-claude-code-hooks.md))

| Feature                        | Description                                                                                                                                    |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| 🪝 **`tokenso claude install`** | Merges Tokenso hooks into `.claude/settings.json` (preserves your existing settings; `--local` for settings.local.json)                       |
| 🚀 **SessionStart hook**       | Injects memory state + symbol-map stats (~150 tokens) at session start — zero exploration needed                                              |
| 🛡️ **Read guard**              | Blocks blind full-file reads over `TOKENSO_READ_GUARD_TOKENS` (default 2000) and redirects Claude to `tokenso symbols` + line-range reads     |
| 💾 **PreCompact checkpoint**   | Auto-runs `tokenso save` before context compaction so memory survives                                                                          |
| 📟 **Statusline**              | Live `🧠 tokenso ⏐ saved ~5.3M tokens (≈$15.83)` in the Claude Code status bar                                                                 |
| 🔍 **`tokenso claude status`** | Shows which hooks are active; `tokenso claude uninstall` removes only Tokenso-owned entries                                                    |

<details>
<summary><strong>📜 Release History</strong></summary>

<br />

**v3.6.0** — Enhanced AI tool detection: Cline, VS Code, Cursor by process + extension + config; live status icons in `tokenso graph`

**v3.4.0** — Real tokenizer + enhanced memory graph: tiktoken integration, 10 cognitive nodes, token distribution
**v3.3.0** — Enhanced memory graph: token distribution, session delta, token density, 10 cognitive nodes
**v3.2.0** — `tokenso brief` — auto-generate architecture briefing for AI agents
**v3.1.0** — Memory graph token detection: read token memory across sessions, sparkline trends
**v3.0.0** — Token Memory Graph, 6-phase mindmap, cognitive synapses, machine-readable graph
**v2.9.0** — Command polish: symbol-aware search, session subcommands, enhanced status & doctor
**v2.8.2** — Self-heal for the `tk` alias
**v2.8.1** — Short alias `tk` for `tokenso`
**v2.8.0** — `tokenso smart` health linter with `--fix` mode
**v2.7.1** — Discoverability fix for help screen & autocompletion
**v2.7.0** — Honest telemetry with `tokenso wrap`, structured-output parsing, observed activity dashboard
**v2.6.0** — Symbol map — biggest token-saving upgrade since repo map
**v2.5.1** — Atomic self-update (critical fix)
**v2.5.0** — Dashboard polish: sparklines, count-up animations, print/PDF, copy stats
**v2.4.0** — ADR governance & architecture skill
**v2.3.0** — `tokenso smart`, `tokenso watch`, `tokenso doctor`, `tokenso status`
**v2.2.0** — Production hardening: idempotent installer, offline dashboard, accessibility

</details>

---

## ⚡ Install

Run **once** on your machine to install the `tokenso` command globally:

```bash
curl -fsSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/install.sh | bash
```

For CI or unattended setups:

```bash
curl -fsSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/install.sh | bash -s -- -y
```

> The installer auto-switches to unattended mode when no TTY is detected — works in VS Code terminals, Codespaces, headless containers, and more.

---

## 🚀 Quick Start

```bash
tokenso install        # Interactive wizard — select your AI tools
tokenso smart          # AI agent autopilot — one command, everything happens
tokenso run            # Launch the cognitive mindmap with token memory graph
```

The install wizard lets you pick any combination of 16+ AI tools:

```
── AI Coding Agents ──────────────────────────────
 1) Claude Code          6) Gemini CLI          11) Void Editor
 2) Cline                7) Aider               12) Zed AI
 3) Roo Code             8) Continue.dev        13) PearAI
 4) Kilo                 9) Cursor              14) GitHub Copilot
 5) Open Code           10) Windsurf            15) Amazon Q
                                            16) ⭐ Antigravity
       0) 🎯 ALL of them
```

---

## 💡 How It Works

Tokenso operates in **three layers**:

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   1. MAP                                                    │
│      Generates ultra-compressed repo map at                 │
│      .ai-memory/repo-map.txt                                │
│      (~1% of original token cost)                           │
│                                                             │
│   2. INJECT                                                 │
│      Drops search diet rules + memory protocol              │
│      into your AI tool's config files                       │
│      (auto-applied every session)                           │
│                                                             │
│   3. TRACK                                                  │
│      Records tokens saved, cost reduction,                  │
│      milestones — with sparkline trends                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

| Without Tokenso                     | With Tokenso                                  |
| ----------------------------------- | --------------------------------------------- |
| AI runs `ls -R` & reads whole files | AI reads a tiny compressed map (~1%)          |
| AI forgets work and loops           | AI writes milestones to `.ai-memory/state.md` |
| Tokens explode every session        | Context stays clean, savings compound         |
| You manually track savings          | `tokenso smart` handles everything            |

---

## 🤖 AI Agent Autopilot

`tokenso smart` is designed for AI agents to run at the **start of every session** — 7 steps, zero prompts:

| Step | Action                             | Auto |
| ---- | ---------------------------------- | ---- |
| 1    | Auto-init `.ai-memory/` if missing | ✅   |
| 2    | Refresh stale repo map             | ✅   |
| 3    | Save session stats                 | ✅   |
| 4    | Manage background watcher          | ✅   |
| 5    | Diagnose issues (jq, rg, bc, JSON) | ✅   |
| 6    | Read & return `state.md`           | ✅   |
| 7    | Suggest next actions               | ✅   |

```bash
tokenso smart            # Text report
tokenso smart --json     # Machine-readable JSON for scripts
```

### AI Agent Workflow

```
Agent starts → tokenso smart --json → Read state.md from JSON
                                          │
                                          ▼
                                     Does work...
                                          │
                                          ▼
                              tokenso save "completed X"
                                          │
                                          ▼
                              tokenso smart --json  ← checkpoint
```

---

## 👁 Background Auto-Save

```bash
tokenso watch start       # Start daemon (checks every 60s)
tokenso watch start 120   # Custom interval
tokenso watch status      # Is it running?
tokenso watch log         # Recent activity
tokenso watch stop        # Stop the daemon
```

> Not a dumb timer — compares file mtimes and only triggers when something actually changed. No changes = zero I/O.

---

## 🧠 Interactive Mindmap

> Requires `.ai-memory` — run `tokenso install` first.

```bash
tokenso run
```

Launches a **6-phase cognitive mindmap** that scans your workspace, discovers real nodes, reads token memory from history, fires animated synapses, and saves a machine-readable graph:

```
  ████████╗ ██████╗ ██╗  ██╗███████╗███╗   ██╗ ██████╗
  ╚══██╔══╝██╔═══██╗██║ ██╔╝██╔════╝████╗  ██║██╔═══██╗
     ██║   ██║   ██║█████╔╝ █████╗  ██╔██╗ ██║██║   ██║
     ██║   ██║   ██║██╔═██╗ ██╔══╝  ██║╚██╗██║██║   ██║
     ██║   ╚██████╔╝██║  ██╗███████╗██║ ╚████║╚██████╔╝
     ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝
           Cognitive Mindmap Search  v3.5.0

  🔍 Phase 1: Scanning project workspace...
  ◉  Discovered [Workspace Code] ... 47 source files
  ◉  Discovered [Token Memory]  ... 35 sessions, 972,764 tokens recalled
  ◉  Discovered [Semantic Map]  ... 24-line compressed map

  ⚡ Phase 2: Firing cognitive synapses...
    Linked: [Token Memory] ═══> [Semantic Map]  ✔
    Linked: [Token Memory] ═══> [Memory State]  ✔

  🧠 Phase 3: Reading token memory...
    Savings trend: ▂▂▅▅████
    Recent milestones recalled from history

  ✨ 6 cognitive modules linked | 99% context reduction
```

### Token Memory Graph JSON

Saved to `.ai-memory/token-memory-graph.json` for AI agents:

```json
{
  "schema": 1,
  "version": "3.0.0",
  "nodes": {
    "workspace_code": { "raw_tokens": 148200, "files": 47 },
    "semantic_map": { "map_tokens": 1240, "compression_pct": 99 },
    "token_memory": { "sessions": 35, "cumulative_saved": 972764 }
  },
  "edges": [
    {
      "from": "token_memory",
      "to": "semantic_map",
      "data": "history→compression trend"
    }
  ]
}
```

---

## 📊 Dashboard & Stats

### Terminal Dashboard

```
📁 Project:  my-awesome-app    Installed: 2026-05-17
🤖 Active agents: Claude Code  Cursor  GitHub Copilot
── THIS SESSION ─────────────────────────────────────
  Full project scan:      148,200 tokens
  Optimized map:            1,240 tokens
  Tokens saved:           146,960  (~99%)
  Est. cost saved:           $0.44

  Reduction: [████████████████████████████████████░░░]  99%

── ALL TIME ─────────────────────────────────────────
  Total sessions:                12
  Total tokens saved:     1,763,520
  Total cost saved:            $5.29
  Savings trend:          [▅▅████████]
```

### HTML Visual Dashboard

```bash
tokenso stats --html      # Premium glassmorphic dashboard with charts
tokenso stats --json      # JSON for scripts & integrations
tokenso stats --csv       # CSV for spreadsheets
```

Opens a glassmorphic single-file HTML page with savings trend charts, radial gauge, model cost comparisons, and an interactive ROI calculator — no server required.

---

## 🔍 Zero-Waste Code Search

```bash
tokenso search "handleSubmit"
```

Returns symbol map matches + code snippets — capped at 15 results to keep AI context lean:

```
🔍 Zero-Waste Code Search  Query: 'handleSubmit'

  [ 🔣 Symbol Map Matches ]
    • src/forms/LoginForm.tsx:42  function  handleSubmit
    • src/hooks/useForm.ts:15     function  handleSubmit

  [ 📝 Source Code Matches (Max 15) ]
  📂 src/forms/LoginForm.tsx
     Line 42: const handleSubmit = async (e) => {
```

---

## 🧠 Memory State

```bash
tokenso state              # View AI memory checklist
tokenso save "note"        # Save a milestone after completing work
```

The state file (`.ai-memory/state.md`) tracks completed tasks, next actions, blocked items, and key context — so the AI picks up where it left off without re-reading the codebase.

---

## 🔧 Commands

### Daily Use

| Command           | Description                               |
| ----------------- | ----------------------------------------- |
| `tk`              | Smart status — tokens saved, next action  |
| `tk save`         | Update repo map & record token stats      |
| `tk save "note"`  | Save stats with a milestone note          |
| `tk search <q>`   | Zero-waste codebase search                |
| `tk state`        | View & edit AI memory checklist           |
| `tk stats`        | Detailed token report                     |
| `tk stats --html` | Premium HTML dashboard                    |
| `tk run`          | Cognitive mindmap with token memory graph |
| `tk map`          | Colorized repository structure tree       |
| `tk graph`        | Read token memory graph (use --json for raw) |
| `tk smart`        | AI agent autopilot                        |

### Management (`tk config <subcommand>`)

| Command                 | Description                |
| ----------------------- | -------------------------- |
| `tk config install`     | Project setup wizard       |
| `tk config watch start` | Start background auto-save |
| `tk config watch stop`  | Stop the daemon            |
| `tk config update`      | Self-update from GitHub    |
| `tk config doctor`      | Environment diagnostics    |
| `tk config clean`       | Wipe cached files          |
| `tk config reset`       | Clear cumulative stats     |

> **Tip:** `tk` is a short alias for `tokenso` — both work everywhere. All old commands (`tokenso install`, etc.) still work with a redirect hint.

---

## 🩺 Troubleshooting

<details>
<summary><strong>Command not found</strong></summary>

```bash
source ~/.zshrc    # or ~/.bashrc — pick up the new PATH
```

If still missing:

```bash
echo "$PATH" | tr ':' '\n' | grep -E '(/usr/local/bin|\.local/bin)'
```

</details>

<details>
<summary><strong>Permission denied</strong></summary>

```bash
mkdir -p "$HOME/.local/bin"
curl -fsSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/install.sh | bash
```

macOS Gatekeeper: `xattr -d com.apple.quarantine /usr/local/bin/tokenso`

</details>

<details>
<summary><strong>Missing dependencies</strong></summary>

| Tool   | Improves            | Without it         |
| ------ | ------------------- | ------------------ |
| `jq`   | JSON parsing        | grep/awk fallback  |
| `bc`   | Precision math      | awk fallback       |
| `rg`   | Fast search         | find/grep fallback |
| `tree` | Pretty maps         | flat find listing  |
| `perl` | Search highlighting | sed fallback       |

Install: `brew install jq ripgrep tree` or `apt install jq ripgrep tree`

</details>

<details>
<summary><strong>Corrupt stats / reinstall / uninstall</strong></summary>

**Reset stats:**

```bash
tokenso reset
```

**Uninstall:**

```bash
tokenso watch stop 2>/dev/null
rm -f "$(command -v tokenso)" "$HOME/.tokenso_completion.sh"
# Remove marker-bracketed blocks from ~/.zshrc or ~/.bashrc
```

</details>

---

## 🤝 Compatibility

### AI Coding Agents

| Tool           | Config                               |
| -------------- | ------------------------------------ |
| Claude Code    | `.claudecode` + `CLAUDE.md`          |
| Cline          | `.clinerules`                        |
| Roo Code       | `.roomodes`                          |
| Kilo           | `.kilorules`                         |
| Gemini CLI     | `.geminirules`                       |
| Open Code      | `.opencode`                          |
| Aider          | `CONVENTIONS.md` + `.aider.conf.yml` |
| Continue.dev   | `.continue/config.yaml`              |
| ⭐ Antigravity | Global skill + `.geminirules`        |

### AI-Powered Editors

| Tool        | Config                            |
| ----------- | --------------------------------- |
| Cursor      | `.cursorrules` + `.cursor/rules/` |
| Windsurf    | `.windsurfrules`                  |
| Void Editor | `.voidrules`                      |
| Zed AI      | `.zed/assistant-rules.md`         |
| PearAI      | `.pearai`                         |

### Enterprise & Cloud

| Tool               | Config                            |
| ------------------ | --------------------------------- |
| GitHub Copilot     | `.github/copilot-instructions.md` |
| Amazon Q Developer | `.amazonq/rules/`                 |

---

## 📁 Project Structure

```
.
├── bin/tokenso               # Main CLI (pure Bash, ~3,400 lines)
├── scripts/
│   ├── init-smart-search.sh  # Compressed repo map generator
│   └── apply-cross-rules.sh  # Cross-tool rule injection
├── docs/
│   ├── adr/                  # Architecture Decision Records
│   └── superpowers/          # Design specs & plans
├── install.sh                # Global installer
├── CLAUDE.md                 # Claude Code rules
├── SKILL.md                  # Antigravity skill definition
└── README.md
```

### Generated at runtime (per project)

```
.ai-memory/
├── repo-map.txt              # Ultra-compressed directory tree
├── optimizer-stats.json      # Session history & cumulative savings
├── state.md                  # AI memory checklist
├── token-memory-graph.json   # Machine-readable graph (new!)
├── symbol-map.txt            # Function/class/type index
└── sessions/                 # Wrapped session manifests
```

---

## 🤝 Contributing

PRs and issues welcome at [github.com/Basharlouzon/Token-save---optimizer](https://github.com/Basharlouzon/Token-save---optimizer).

```bash
git clone https://github.com/Basharlouzon/Token-save---optimizer.git
cd Token-save---optimizer
bash bin/tokenso install      # test the installer
bash bin/tokenso run          # test the mindmap
```

---

## 📄 License

MIT License — free to use, modify, and distribute. See [LICENSE](LICENSE).

<br />

<div align="center">

**[⬆ Back to Top](#-tokenso)**

Made with 🧠 by [Bashar Louzon](https://github.com/Basharlouzon)

</div>
