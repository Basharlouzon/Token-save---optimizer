# Tokenso 🧠🔋

[![Version](https://img.shields.io/badge/version-2.5.0-00bcd4?style=flat-square)](https://github.com/Basharlouzon/Token-save---optimizer)
[![License: MIT](https://img.shields.io/badge/license-MIT-00e676?style=flat-square)](LICENSE)
[![Shell](https://img.shields.io/badge/pure%20bash-100%25-4a90d9?style=flat-square)]()

> **Stop AI agents from wasting tokens, looping, and reading your entire codebase.**

AI coding agents burn tokens fast — they read entire files to find one line, dump massive search results into context, and loop over old mistakes. **Tokenso** puts your agents on a strict search diet with a persistent memory protocol, working across **16+ AI tools** out of the box.

Every session, Tokenso tracks exactly how many tokens and dollars you saved — with a live terminal dashboard and a premium HTML export with interactive charts.

---

## ✨ What's new in 2.5.0

A dashboard polish release.

- **Mini-sparklines in stat cards** — Each of the four KPI cards now has an inline trend line drawn from your last 10 sessions of history. Empty-state copy when there's not enough data yet.
- **Animated count-up numbers** — Stat values ease from 0 to their final value on load, respecting `prefers-reduced-motion`.
- **Copy stats as Markdown** — New "Copy" button in the header bundles project name, all KPIs, and recent milestones into a paste-ready Markdown table. Falls back to `execCommand` when the Clipboard API is blocked.
- **Print / Save-as-PDF** — New "Print" button + a full `@media print` stylesheet renders a clean black-on-white version that fits cleanly on a single page, with sparklines preserved.
- **Dynamic footer version** — Footer now reads `VERSION` from the runtime data instead of the previously hardcoded `v2.2.0`.
- **Toast notifications** — Subtle bottom-center toast confirms copy actions.
- **Keyboard shortcuts** — Press `C` to copy stats, `P` to print (ignored while focused on inputs).

## ✨ What's new in 2.4.0

A governance and decision-tracking release.

- **`/architecture` skill** — New local skill at `.claude/skills/architecture/` that produces lightweight ADRs in `docs/adr/` with Tokenso-specific scoring dimensions (token cost, bash portability, install surface, cross-tool reach).
- **ADR process adopted** — See `docs/adr/0001-adopt-adr-process.md`. Future non-trivial design decisions land as numbered, greppable markdown files alongside the code.
- **Persistent release rules** — `CLAUDE.md` now codifies the version-bump + push-to-master flow so every agent session ships changes consistently.

## ✨ What's new in 2.3.0

A reliability and diagnostics release.

- **`tokenso doctor`** — New diagnostics command that checks dependencies, project state, JSON health, and active tool configs with pass/warn/fail output.
- **`tokenso status`** — Quick one-line project health check (sessions, tokens saved, agents, map size).
- **No more hanging.** Replaced all fragile `exec < /dev/tty` redirects with per-prompt `< /dev/tty` reads throughout `tokenso install`, `tokenso save`, and `tokenso state`.
- **Smarter self-update.** `tokenso update` now fetches the remote version first and skips the download if already current.
- **Graceful search without perl.** Search highlighting falls back to `sed` when `perl` isn't installed.
- **Enhanced state.md template.** New installs include `## Blocked` and `## Decisions` sections for richer AI memory tracking.
- **Temp file cleanup.** An EXIT trap now removes `.ai-memory/temp_search_matches.txt` on every run.
- **Fixed timing.** Search elapsed-time display no longer shows wrong values when `date +%s` isn't available.

## ✨ What's new in 2.2.0

A production-hardening release. Everything you ran before still works the same way — it just fails less.

- **Idempotent installer.** Re-running `install.sh` no longer duplicates PATH or completion blocks in your shell profile; appended lines are now bracketed with `# >>> tokenso path >>>` markers and skipped on subsequent runs.
- **Safer downloads.** The remote installer now downloads to a temp file, verifies size and shebang, and installs atomically with `install(1)`. A failed `curl` no longer leaves a half-written binary on PATH.
- **Robust stats parsing.** `bin/tokenso` prefers `jq` for `.ai-memory/optimizer-stats.json` and falls back to grep/awk with integer validation. Corrupt JSON now recovers to defaults with a warning instead of crashing.
- **Optional dependencies.** Missing `bc`, `jq`, `rg`, or `tree`? Tokenso degrades gracefully — `bc` falls back to `awk` for cost math, `rg` falls back to `find`, and so on. See [Troubleshooting](#-troubleshooting) for the full table.
- **Offline-friendly dashboard.** The HTML export now ships with a `ui-sans-serif`/`ui-monospace` system-font fallback and renders fully without network. Charts are memoized, resize is debounced, and chart points support keyboard focus and touch alongside hover.
- **Accessibility.** ARIA labels on gauge/milestones/chart points, units on ROI sliders ("15 runs/day", "5,000 tokens/run"), and a dashed accent line on the savings chart so colorblind users can still distinguish the trend.
- **Bash safety.** `set -o pipefail` + `ERR` traps in the installer, `set -euo pipefail` in helper scripts, unified `rg`/`find` exclusion lists so the two code paths cannot drift.

Upgrade with `tokenso update` or re-run the install one-liner below — the new installer is idempotent.

---

## ⚡ Install

Run **once** on your machine to install the `tokenso` command globally:

```bash
curl -fsSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/install.sh | bash
```

For CI or unattended setups (no interactive prompts):

```bash
curl -fsSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/install.sh | bash -s -- -y
```

> The installer probes for a usable controlling terminal and **auto-switches to unattended mode** if it can't find one — so the `curl | bash` one-liner also works cleanly inside VS Code's integrated terminal, GitHub Codespaces, headless containers, and other contexts where `/dev/tty` isn't available. The inner `bin/tokenso` download is timeout-bounded; no more silent multi-minute hangs on a slow CDN.

---

## 🚀 Quick Start

Initialize Tokenso in any project:

```bash
tokenso install
```

An interactive wizard launches — select any combination of AI tools you use:

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

Select **multiple tools** with space-separated numbers, or `0` for all. Tokenso injects optimized rules into each config file and generates a compressed repo map — everything starts working immediately.

---

## 💡 How It Works

Tokenso operates in three layers:

1. **Map** — Generates an ultra-compressed repository map at `.ai-memory/repo-map.txt` (excludes `node_modules`, `.git`, binaries, etc.). Instead of running `ls -R` or reading whole files, the AI reads this tiny file to understand project structure.

2. **Inject** — Drops search diet rules and memory protocol instructions into your AI tool's config files (`.cursorrules`, `.clinerules`, `.claudecode`, etc.). The AI automatically follows them on every session.

3. **Track** — Every `tokenso save` records tokens saved, estimated cost reduction, and milestones. Cumulative stats grow over time with a sparkline trend.

| Without Tokenso | With Tokenso |
|---|---|
| AI runs `ls -R` & reads whole files | AI reads a tiny compressed map (~1% of original) |
| AI forgets work and loops | AI writes milestones to `.ai-memory/state.md` |
| Tokens explode every session | Context stays clean and savings compound |

Once installed, **you don't need to do anything**. The AI reads the rules automatically. If you notice it looping, just tell it:

> *"Please refresh your memory state."*

---

## 🧠 Interactive Mindmap

> Requires `.ai-memory` to exist — run `tokenso install` (or `bash scripts/init-smart-search.sh .`) first.

Run `tokenso run` to launch the cognitive mindmap — Tokenso scans your workspace, discovers code nodes, fires synapses to link them, and saves the optimized map:

```
  ████████╗ ██████╗ ██╗  ██╗███████╗███╗   ██╗ ██████╗ 
  ╚══██╔══╝██╔═══██╗██║ ██╔╝██╔════╝████╗  ██║██╔═══██╗
     ██║   ██║   ██║█████╔╝ █████╗  ██╔██╗ ██║██║   ██║
     ██║   ██║   ██║██╔═██╗ ██╔══╝  ██║╚██╗██║██║   ██║
     ██║   ╚██████╔╝██║  ██╗███████╗██║ ╚████║╚██████╔╝
     ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ 
            Cognitive Mindmap Search  v2.2.0

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
```

---

## 📊 Dashboard & Stats

### Terminal Dashboard

Type `tokenso` or `tokenso stats` in any initialized project:

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

### HTML Visual Dashboard

Generate a premium offline dashboard with interactive charts, ROI simulator, and milestone timeline:

```bash
tokenso stats --html
```

Opens a glassmorphic single-file HTML page with savings trend charts, a radial gauge, model cost comparisons, and an interactive savings calculator — no server required. The dashboard ships with a system-font fallback so it renders fully even when offline.

### Export Formats

```bash
tokenso stats --json    # JSON output for scripts and integrations
tokenso stats --csv     # CSV for spreadsheets and analysis
```

---

## 🔍 Zero-Waste Code Search

Search your codebase without flooding the AI's context window:

```bash
tokenso search "handleSubmit"
```

Returns file path matches from the repo map plus top code snippets with highlighted matches — capped at the top 15 source-code matches to keep AI context lean (file-path matches from the repo map are not capped):

```
🔍 Zero-Waste Code Search  Query: 'handleSubmit'

  [ 📁 Codebase Blueprint Matches ]
  ─────────────────────────────────────────
    • src/forms/LoginForm.tsx
    • src/hooks/useForm.ts

  [ 📝 Source Code Matches (Max 15) ]
  ─────────────────────────────────────────
  📂 src/forms/LoginForm.tsx
     Line 42: const handleSubmit = async (e) => {

  Searched 47 files | Found 3 matches | Showing top 2 | Done in 0s
```

---

## 🧠 Memory State Management

Tokenso maintains a persistent task tracker that AI agents read and write to:

```bash
# View current AI memory state
tokenso state

# Save a milestone note after completing work
tokenso save "Implemented auth flow with JWT tokens"
```

The state file (`.ai-memory/state.md`) tracks completed tasks, next actions, and key architectural decisions — so the AI can pick up where it left off without re-reading the entire codebase.

---

## 🗺 Repository Map

View the colorized compressed tree of your project:

```bash
tokenso map
```

Shows a syntax-highlighted directory tree with file/folder counts and estimated token weight — the same map the AI reads instead of exploring manually.

---

## 🛠 All Commands

| Command | Description |
|---|---|
| `tokenso` | Live terminal dashboard with stats |
| `tokenso run` | Interactive cognitive mindmap & stats save |
| `tokenso install` | Project setup wizard (select AI tools) |
| `tokenso save` | Update repo map & record token stats |
| `tokenso save "note"` | Save stats with a milestone note |
| `tokenso search \<query\>` | Zero-waste codebase search |
| `tokenso state` | View & edit AI memory checklist |
| `tokenso map` | Colorized repository structure tree |
| `tokenso stats` | Detailed token report |
| `tokenso stats --html` | Generate visual HTML dashboard |
| `tokenso stats --json` | Export stats as JSON |
| `tokenso stats --csv` | Export stats as CSV |
| `tokenso clean` | Wipe cached optimizer files for this project |
| `tokenso reset` | Clear cumulative stats history |
| `tokenso update` | Self-update from GitHub |
| `tokenso doctor` | Run environment diagnostics |
| `tokenso status` | Quick one-line project health check |
| `tokenso --version` | Show version |

---

## 🩺 Troubleshooting

### `tokenso: command not found`

The installer appended a PATH block to your shell profile but the current shell hasn't picked it up yet.

```bash
source ~/.zshrc          # or ~/.bashrc / ~/.bash_profile / ~/.profile
# or just open a new terminal window
```

If it still isn't found, check that the install directory is on PATH:

```bash
echo "$PATH" | tr ':' '\n' | grep -E '(/usr/local/bin|\.local/bin)'
```

### Permission denied on install

The installer falls back to `sudo` automatically when the target is system-owned. If `sudo` is unavailable, point the installer at a user-writable location:

```bash
mkdir -p "$HOME/.local/bin"
curl -fsSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/install.sh | bash
```

On macOS, if Gatekeeper blocks the script, open **System Settings → Privacy & Security** and allow the file, or run `xattr -d com.apple.quarantine /usr/local/bin/tokenso`.

### Missing dependencies

Tokenso prefers but does not require these tools:

| Tool | What it improves | Without it |
|---|---|---|
| `jq` | Robust JSON parsing of stats | Falls back to a small grep/awk reader |
| `bc` | High-precision USD math | Falls back to `awk` arithmetic |
| `rg` (ripgrep) | Faster file enumeration and search | Falls back to `find` / `grep` |
| `tree` | Pretty repo-map rendering | Falls back to a flat `find` listing |

Install any of these via your package manager (`brew install jq ripgrep tree`, `apt install jq ripgrep tree`, etc.).

### Reinstalling / uninstalling

The installer is idempotent — re-running `install.sh` will not duplicate PATH or completion blocks (they are bracketed with `# >>> tokenso path >>>` markers).

To fully uninstall:

```bash
rm -f "$(command -v tokenso)" "$HOME/.tokenso_completion.sh"
# Remove the marker-bracketed blocks from your shell profile (~/.zshrc, ~/.bashrc, etc.)
```

### Installer looks stuck

If the installer appears frozen at `○ Copying Tokenso executable to target...`:

- **Most common cause:** `sudo` is silently waiting for your password. The installer now prints `🔐 Your sudo password is required next:` immediately before the prompt — if you see that line, type your password (it won't echo).
- **Slow network:** The inner `bin/tokenso` download has a 10-second connect timeout and 120-second total timeout. If you're behind a proxy, set `HTTPS_PROXY` and re-run.
- **No TTY (CI / IDE terminals):** The installer auto-detects this and switches to unattended mode with a clear warning. If you still want unattended mode explicitly, pass `-y`.

### Corrupt or stale stats

If `tokenso` warns about non-numeric fields in `.ai-memory/optimizer-stats.json`, reset the cumulative history while keeping your install date:

```bash
tokenso reset
```

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

## 🤝 Contributing

PRs and issues are welcome at [github.com/Basharlouzon/Token-save---optimizer](https://github.com/Basharlouzon/Token-save---optimizer).

---

## 📄 License

MIT License — free to use, modify, and distribute. See [LICENSE](LICENSE).
