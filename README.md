tok# Tokenso 🧠🔋

[![Version](https://img.shields.io/badge/version-2.9.0-00bcd4?style=flat-square)](https://github.com/Basharlouzon/Token-save---optimizer)
[![License: MIT](https://img.shields.io/badge/license-MIT-00e676?style=flat-square)](LICENSE)
[![Shell](https://img.shields.io/badge/pure%20bash-100%25-4a90d9?style=flat-square)]()
[![AI Tools](https://img.shields.io/badge/compatible-16%2B%20AI%20tools-ff6b6b?style=flat-square)]()
[![Tokens Saved](https://img.shields.io/badge/avg_savings-99%25%20context-00e676?style=flat-square)]()

> **Stop AI agents from wasting tokens, looping, and reading your entire codebase.**

AI coding agents burn tokens fast — they read entire files to find one line, dump massive search results into context, and loop over old mistakes. **Tokenso** puts your agents on a strict search diet with a persistent memory protocol, working across **16+ AI tools** out of the box.

Every session, Tokenso tracks exactly how many tokens and dollars you saved — with a live terminal dashboard and a premium HTML export with interactive charts.

---

## ✨ What's new in 2.9.0

Command polish — four upgrades that wire existing v2.6/v2.7/v2.8 data into the commands you actually run.

- **`tokenso search` is now symbol-aware.** A new `[ 🔣 Symbol Map Matches ]` section appears first in results, showing `path:line  kind  name` for any symbol matching your query — no need to remember whether to run `search` or `symbols`.
- **`tokenso sessions` subcommands**:
  - `tokenso sessions show <id|prefix>` — full manifest + log location
  - `tokenso sessions last` — most recent session
  - `tokenso sessions prune --keep N` — delete all but newest N
  - `tokenso sessions prune --keep-days N` — delete sessions older than N days
  - Add `--dry-run` to preview deletions
- **`tokenso status` shows observed activity.** Now includes symbol count, a `watch:on` indicator when the watcher is running, and a second line `↳ Observed: X wrap session(s), last Nm ago` when wraps exist.
- **`tokenso doctor` checks more**:
  - `tk` short-alias symlink integrity (warns if a real file shadows it, ok if symlink, suggests self-heal if missing)
  - `symbol-map.txt` presence + non-emptiness (catches silent extractor failures)
  - Wrapped-session count (warns when > 100, suggests `tokenso sessions prune`)
- See [ADR-0007](docs/adr/0007-command-polish.md).

## ✨ What's new in 2.8.2

Self-heal for the `tk` alias.

- Users updating from a pre-2.8.1 version got the new binary but no `tk` symlink (the old `run_update` didn't know to create it). 2.8.2 fixes that: every `tokenso` invocation now ensures `tk` exists in the same directory as the canonical binary. The check is a single `[ -L ]` test on the happy path — no perceptible overhead.
- Safe semantics: only creates the symlink when `tk` is absent or already a symlink. Never overwrites a real file named `tk` the user may own.

## ✨ What's new in 2.8.1

Short alias `tk` for `tokenso`.

- `install.sh` now creates a `tk` symlink next to the `tokenso` binary, so `tk smart`, `tk symbols foo`, `tk wrap claude ...` all work.
- `tokenso update` self-heals the symlink on each update — no re-install needed for existing users.
- Bash and zsh autocompletion are wired to both names.
- The canonical name is still `tokenso` — repo, brand, badge, and docs unchanged. `tk` is purely a typing shortcut.

## ✨ What's new in 2.8.0

`tokenso smart` is now a health linter — silent rot in `state.md` and friends gets caught at the moment your agent reads it.

- **`state.md` rot detection** — flags non-heading first lines (e.g. `x# AI Memory State`), low-signal milestone lines (`! test`, `! tes`, `! foo`, `! debug`…), consecutive duplicates, and bloat (> 200 lines).
- **Empty symbol-map detection** — `.ai-memory/symbol-map.txt` exists but extractor produced 0 symbols.
- **All-estimated trust gap** — if you have ≥ 5 sessions but 0 `tokenso wrap` sessions, gentle nudge that your savings number is fully estimated.
- **Session-manifest bloat** — > 100 wrap manifests in `.ai-memory/sessions/` triggers a prune suggestion.
- **`tokenso smart --fix`** — opt-in: auto-applies the safe cleanups (strip line-1 garbage, remove leftover test milestones, de-dup consecutive duplicates). Read-only checks stay read-only.
- See [ADR-0006](docs/adr/0006-smart-linter.md).

## ✨ What's new in 2.7.1

Discoverability fix.

- **`tokenso help` now lists the v2.6 and v2.7 commands** (`symbols`, `wrap`, `sessions`) — they were dispatched correctly but missing from the help screen.
- **Shell autocomplete updated** in `install.sh` to include `symbols`, `wrap`, `sessions`, `smart`, `watch`, `doctor`, `status` plus subcompletions for `watch start|stop|status`. Re-run `install.sh` (or run the install one-liner) to refresh your `~/.tokenso_completion.sh`.

## ✨ What's new in 2.7.0

Honest telemetry — measure agent activity instead of estimating it.

- **`tokenso wrap <cmd> [args...]`** — Spawn any agent CLI as a subprocess, tee stdout/stderr to a session log, capture git-tree delta + duration + (when available) exact tool-call counts. Session manifest at `.ai-memory/sessions/<id>.json`.
- **Structured-output parsing** — Pass `--output-format stream-json` to `claude -p` and Tokenso extracts exact `Read` / `Search` / `Bash` / `Edit` / `Write` counts and approximate bytes read from `tool_result` content. Uses `jq` if present, `grep -c` fallback.
- **Best-effort heuristics for plain CLIs** — Even without structured output, every wrapped session gets duration, exit code, and git diff size recorded.
- **`tokenso sessions`** — List the last 20 wrapped sessions with start time, duration, exit code, and tool-call counts.
- **Dashboard: "Observed Activity" panel** — New REAL-badged panel separate from the existing Estimated cards. Shows aggregated Read/Search/Bash/Edit counts and bytes read across all wrapped sessions. Empty state shows the recipe for first-time users.
- **Agent rules bumped to v3** — Adds an "Observable Sessions" rule telling agents to use `tokenso wrap` when launching nested CLI agents.
- See [ADR-0005](docs/adr/0005-honest-telemetry.md).

### Maximum-observability recipe

```bash
tokenso wrap claude -p "fix the bug" --output-format stream-json
```

## ✨ What's new in 2.6.0

Symbol map — the biggest token-saving upgrade since the repo map itself.

- **`.ai-memory/symbol-map.txt`** — One line per function/class/type: `path:line<TAB>kind<TAB>name`. Agents can now answer "where is `handleAuth`?" without reading any file. Built automatically by `tokenso map` and `tokenso smart`.
- **`tokenso symbols [name]`** — New command to view/filter the symbol index from the terminal. `tokenso symbols drawGauge` shows every match with its file/line.
- **Two extraction backends** — Universal Ctags when installed (40+ languages); portable awk regex fallback for JS/TS, Python, Bash, Go, Rust, Ruby. Capped at 800 symbols (`TOKENSO_SYMBOL_CAP`) so the map stays token-light.
- **Agent rules bumped to v2** — The injected rules now include a "Symbol Lookup First" rule telling agents to check the symbol map BEFORE opening files. `apply-cross-rules.sh` re-injects automatically.
- **Dashboard** — New "Indexed Symbols" stat in the project details bar.
- **Smart report** — Adds `symbols: N` line and "Refreshed symbol map" action.
- See [ADR-0004](docs/adr/0004-symbol-map.md).

## ✨ What's new in 2.5.1

A critical fix release.

- **`tokenso update` is now atomic.** The previous implementation streamed the new binary directly over the live `tokenso` on PATH. A Ctrl+C, network drop, or bad payload would leave your install truncated and broken (typical symptom: `unexpected EOF while looking for matching '}'`). The updater now downloads to a temp file, validates (size > 10KB, shebang present, `bash -n` passes), and atomically replaces the binary via `install(1)` (with `mv` fallback). On *any* failure, your existing tokenso is left untouched.
- Better network errors: `--connect-timeout 10 --max-time 120`, and a clear "Update aborted; existing tokenso is untouched" message instead of silent corruption.
- See [ADR-0003](docs/adr/0003-atomic-self-update.md).

If you got hit by the v2.5.0 bug, recover with one of:
```bash
curl -sSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/bin/tokenso \
  -o /tmp/tokenso.new && chmod +x /tmp/tokenso.new && mv /tmp/tokenso.new ~/.local/bin/tokenso
# or
curl -sSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/install.sh | bash
```

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

A reliability, automation, and AI-agent integration release.

- **`tokenso smart`** — One command for AI agents to manage everything: auto-init, refresh stale maps, save stats, diagnose issues, read state, and return a structured report. Supports `--json` for machine-readable output. [See below](#-ai-agent-autopilot).
- **`tokenso watch start`** — Background auto-save daemon that only triggers when files actually change (mtimes). Managed via `start`, `stop`, `restart`, `status`, `log`. [See below](#-background-auto-save).
- **`tokenso doctor`** — Diagnostics command that checks dependencies, project state, JSON health, and active tool configs with pass/warn/fail output.
- **`tokenso status`** — Quick one-line project health check (sessions, tokens saved, agents, map size).
- **Token Memory Graph.** `tokenso run` now detects and reads token memory from stats history — a new **[Token Memory]** node displays cumulative savings across sessions, a sparkline trend, and recent milestone recall. Saves a machine-readable graph to `.ai-memory/token-memory-graph.json` with nodes and edges for AI agents to consume.
- **Enhanced mindmap.** `tokenso run` now has 6 phases: scan → synapse → token memory recall → pulse animation → compression estimate → save. Shows real project data (file counts, agent status, state entries), 6 synapse connections between cognitive modules, and a spinner-based save flow.
- **No more hanging.** Replaced all fragile `exec < /dev/tty` redirects with per-prompt `< /dev/tty` reads throughout `tokenso install`, `tokenso save`, and `tokenso state`.
- **Smarter self-update.** `tokenso update` now fetches the remote version first and skips the download if already current.
- **Graceful search without perl.** Search highlighting falls back to `sed` when `perl` isn't installed.
- **Enhanced state.md template.** New installs include `## Blocked` and `## Decisions` sections for richer AI memory tracking.
- **New rule: Smart Mode.** All injected rules now include `tokenso smart` as the first action AI agents should run every session.

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
| You manually track savings | `tokenso smart` handles everything automatically |

Once installed, **you don't need to do anything**. The AI reads the rules automatically. If you notice it looping, just tell it:

> *"Please refresh your memory state."*

---

## 🤖 AI Agent Autopilot

The `tokenso smart` command is designed for AI agents to run at the **start of every session**. It handles the full lifecycle in one call — no interactive prompts, no animations, just clean actionable output.

### What it does (7 steps, zero prompts)

| Step | Action | Auto? |
|------|--------|-------|
| 1. Auto-init | If `.ai-memory/` missing → creates map, stats, state, injects rules | ✅ |
| 2. Refresh stale map | If files changed since last map → regenerates | ✅ |
| 3. Save session stats | Calculates real token savings, updates cumulative totals | ✅ |
| 4. Manage watcher | Checks if background watcher is alive, cleans stale PIDs | ✅ |
| 5. Diagnose issues | Checks jq, rg, bc, JSON validity | ✅ |
| 6. Read state | Returns full `state.md` content in the report | ✅ |
| 7. Suggest actions | Recommends watcher, install, reading state | ✅ |

### Text output

```bash
tokenso smart
```

```
═══ TOKENSO SMART REPORT ═══
project: my-app
version: 2.3.0
session: 14
files: 47
raw_tokens: 148200
map_tokens: 1240
saved_tokens: 146960
saved_pct: 99
cumulative_tokens: 1763520
cumulative_usd: 5.2906
map_lines: 24
watcher: running (PID 12345)
active_tools: Claude Code Cursor GitHub Copilot

── ACTIONS TAKEN ──
  ✓ Refreshed stale repo map
  ✓ Saved session stats (14 sessions, 1,763,520 tokens cumulative)

── SUGGESTIONS ──
  → Read .ai-memory/state.md before starting work to recall prior context

── ISSUES ──
  (none)

── STATE.MD ──
# AI Memory State
## Completed Tasks
- [x] Implemented auth flow with JWT tokens
## Next Actions
- [ ] Wire /api/logout
## Key Context & Architecture
! Refresh tokens live in httpOnly cookies

═══ END REPORT ═══
```

### JSON output (for scripts and integrations)

```bash
tokenso smart --json
```

```json
{
  "version": "2.3.0",
  "project": "my-app",
  "session": 14,
  "files": 47,
  "raw_tokens": 148200,
  "map_tokens": 1240,
  "saved_tokens": 146960,
  "saved_pct": 99,
  "cumulative_tokens": 1763520,
  "cumulative_usd": 5.2906,
  "watcher": "running (PID 12345)",
  "active_tools": "Claude Code Cursor GitHub Copilot",
  "actions_taken": ["Refreshed stale repo map", "Saved session stats"],
  "suggestions": ["Read .ai-memory/state.md before starting work"],
  "issues": [],
  "state": "# AI Memory State\n## Completed Tasks\n..."
}
```

### AI agent workflow

```
Agent starts session
    │
    ▼
tokenso smart --json     ← one command, everything happens
    │
    ├─ Reads state.md from JSON response
    ├─ Checks issues[] — fixes if any
    ├─ Checks suggestions[] — acts on them
    ├─ Now has full context without reading any source files
    │
    ▼
Does work...
    │
    ▼
tokenso save "completed X"
    │
    ▼
tokenso smart --json     ← checkpoint before ending
```

---

## 👁 Background Auto-Save

`tokenso watch` runs a background daemon that automatically saves stats when files change — no cron job needed.

**It's not a dumb timer.** The watcher compares file modification times against the repo map and only triggers a save when something actually changed. No changes = zero I/O.

```bash
tokenso watch start         # start auto-save (checks every 60s)
tokenso watch start 120     # check every 2 minutes instead
tokenso watch status        # is it running?
tokenso watch log           # recent activity
tokenso watch stop          # stop the daemon
tokenso watch restart       # stop + start
```

### How it works

```
┌─────────────────────────────────────────────────┐
│  tokenso watch start                             │
│                                                   │
│  Every 60s (configurable):                       │
│    1. Compare .git/index mtime vs repo-map mtime │
│    2. If git index is newer → files changed      │
│    3. Run tokenso save --silent                  │
│    4. Go back to sleep                           │
│                                                   │
│  If nothing changed → do nothing (zero I/O)      │
└─────────────────────────────────────────────────┘
```

| What | Where |
|------|-------|
| PID file | `.ai-memory/.watch.pid` |
| Log file | `.ai-memory/.watch.log` |
| Logs | `tail -f .ai-memory/.watch.log` |

> The watcher is stopped automatically by `tokenso clean` and survives terminal closure via `nohup` + `disown`.

---

## 🧠 Interactive Mindmap

> Requires `.ai-memory` to exist — run `tokenso install` (or `bash scripts/init-smart-search.sh .`) first.

Run `tokenso run` to launch the cognitive mindmap — Tokenso scans your workspace, discovers real nodes with actual project data, reads token memory from history, fires animated synapses to link 6 cognitive modules, and saves the optimized map with a machine-readable graph:

```
  ████████╗ ██████╗ ██╗  ██╗███████╗███╗   ██╗ ██████╗ 
  ╚══██╔══╝██╔═══██╗██║ ██╔╝██╔════╝████╗  ██║██╔═══██╗
     ██║   ██║   ██║█████╔╝ █████╗  ██╔██╗ ██║██║   ██║
     ██║   ██║   ██║██╔═██╗ ██╔══╝  ██║╚██╗██║██║   ██║
     ██║   ╚██████╔╝██║  ██╗███████╗██║ ╚████║╚██████╔╝
     ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ 
           Cognitive Mindmap Search  v2.3.0

  🔍 Phase 1: Scanning project workspace...
  ◉  Discovered [Workspace Code] ... 47 source files detected
  ◉  Discovered [Context Rules] ... Agent rules active
  ◉  Discovered [Memory State] ... 5 state entries
  ◉  Discovered [Semantic Map] ... 24-line compressed map
  ◉  Discovered [Token Memory] ... 35 sessions, 972,764 cumulative tokens
  ◉  Discovered [Tokenso Core] ... v2.3.0 optimization engine

  ⚡ Phase 2: Firing cognitive synapses to connect nodes...
    Linked:  [Workspace Code] ════════════════> [Semantic Map]  ✔
    Linked:  [Context Rules] ═════════════════> [Memory State]  ✔
    Linked:  [Semantic Map] ══════════════════> [Tokenso Core]  ✔
    Linked:  [Memory State] ══════════════════> [Tokenso Core]  ✔
    Linked:  [Token Memory] ══════════════════> [Semantic Map]  ✔
    Linked:  [Token Memory] ══════════════════> [Memory State]  ✔

  🧠 Phase 3: Reading token memory from history...
    Savings trend: ▂▂▅▅████
    Last 10 sessions recalled from .ai-memory/optimizer-stats.json
    Recent milestones:
    ◆ Implemented auth flow with JWT tokens
    ◆ Wired /api/logout endpoint

  ✨ Cognitive Mindmap Successfully Integrated!
  Compression Vector:  99% context reduction
  Raw Estimate:       148,200 tokens
  Optimized Map:      1,240 tokens
  Tokens Saved:       146,960 tokens  ($0.44 est.)
  Nodes Connected:    6 cognitive modules linked
  Token Memory:       972,764 tokens recalled across 35 sessions
```

The mindmap now runs in **6 phases** — scan, synapse, token memory recall, pulse animation, compression estimate, and save — using **real project data** with cumulative token memory detection.

### Token Memory Graph JSON

After saving, Tokenso generates a machine-readable graph at `.ai-memory/token-memory-graph.json` that AI agents can read to understand the full token savings history:

```json
{
  "schema": 1,
  "version": "2.3.0",
  "nodes": {
    "workspace_code": { "raw_tokens": 148200, "files": 47 },
    "semantic_map":   { "map_tokens": 1240, "compression_pct": 99 },
    "token_memory":   { "sessions": 35, "cumulative_saved": 972764, "history": [...] },
    "memory_state":   { "milestones": ["Implemented auth flow", "..."] },
    "context_rules":  { "active_agents": "Claude Code Cursor" },
    "tokenso_core":   { "version": "2.3.0" }
  },
  "edges": [
    { "from": "workspace_code", "to": "semantic_map", "data": "raw→compressed (99% reduction)" },
    { "from": "token_memory",   "to": "semantic_map", "data": "history→compression trend" },
    ...
  ]
}
```

---

## 📊 Dashboard & Stats

### Terminal Dashboard

Type `tokenso` or `tokenso stats` in any initialized project:

```
📁 Project:  my-awesome-app    Installed: 2026-05-17
🤖 Active agents: Claude Code  Cursor  GitHub Copilot
── THIS SESSION ─────────────────────────────────────
  Full project scan (tokens):      148,200
  Optimized map (tokens):           1,240
  Tokens saved:                   146,960  (~99%)
  Compression ratio:               119.5:1
  Est. cost saved:                 $0.4409

  Reduction: [████████████████████████████████████░░░]  99%

── ALL TIME ─────────────────────────────────────────
  Total AI sessions:            12
  Total tokens saved:           1,763,520
  Total cost saved (est.):      $5.29
  Savings trend (last 10):     [  ▅▅████████]

── ESTIMATED ROI BY MODEL ───────────────────────────
  Model                Rate/1M    This Session    All-Time
  Claude Sonnet 4      $3.00      $0.4409         $5.2906
  Claude Opus 4        $15.00     $2.2044         $26.4528
  Gemini 2.5 Pro       $1.25      $0.1837         $2.2044
  GPT-4.1              $2.00      $0.2939         $3.5270
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

The state file (`.ai-memory/state.md`) tracks completed tasks, next actions, blocked items, architectural decisions, and key context — so the AI can pick up where it left off without re-reading the entire codebase.

---

## 🗺 Repository Map

View the colorized compressed tree of your project:

```bash
tokenso map
```

Shows a syntax-highlighted directory tree with file/folder counts and estimated token weight — the same map the AI reads instead of exploring manually.

---

## 🛠 Commands

### Daily

| Command | Description |
|---|---|
| `tokenso` | Smart status — tokens saved, next action |
| `tokenso save` | Update repo map & record token stats |
| `tokenso save "note"` | Save stats with a milestone note |
| `tokenso search <query>` | Zero-waste codebase search |
| `tokenso state` | View & edit AI memory checklist |
| `tokenso stats` | Detailed token report |
| `tokenso stats --html` | Generate visual HTML dashboard |
| `tokenso stats --json` | Export stats as JSON |
| `tokenso stats --csv` | Export stats as CSV |

### Management (`tokenso config <subcommand>`)

| Command | Description |
|---|---|
| `tokenso config install` | Project setup wizard (select AI tools) |
| `tokenso config watch start` | Start background auto-save daemon |
| `tokenso config watch stop` | Stop the daemon |
| `tokenso config watch status` | Check if watcher is running |
| `tokenso config watch log` | Show recent watcher activity |
| `tokenso config update` | Self-update from GitHub |
| `tokenso config doctor` | Run environment diagnostics |
| `tokenso config clean` | Wipe cached optimizer files for this project |
| `tokenso config reset` | Clear cumulative stats history |

### Other

| Command | Description |
|---|---|
| `tokenso run` | Interactive cognitive mindmap with token memory graph & stats save |
| `tokenso map` | Colorized repository structure tree |
| `tokenso smart` | AI agent autopilot (auto-init, refresh, save, diagnose) |
| `tokenso smart --json` | Same as above, JSON output |
| `tokenso status` | Quick one-line project health check |
| `tokenso help` | Show daily commands |
| `tokenso help all` | Show all commands |
| `tokenso --version` | Show version |

> **Backward compatibility:** All old commands (`tokenso install`, `tokenso watch`, etc.) continue to work and now print a one-line hint pointing to the `config` namespace.

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
| `perl` | Search result highlighting | Falls back to `sed` |

Install any of these via your package manager (`brew install jq ripgrep tree`, `apt install jq ripgrep tree`, etc.).

### Reinstalling / uninstalling

The installer is idempotent — re-running `install.sh` will not duplicate PATH or completion blocks (they are bracketed with `# >>> tokenso path >>>` markers).

To fully uninstall:

```bash
tokenso watch stop 2>/dev/null   # stop any background watcher
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

## 📁 Project Structure

```
.
├── bin/tokenso              # Main CLI binary (pure Bash, ~3,400 lines)
├── scripts/
│   ├── init-smart-search.sh # Compressed repo map generator
│   └── apply-cross-rules.sh # Cross-tool rule injection
├── docs/superpowers/        # Design specs & plans
├── install.sh               # Global installer (curl | bash)
├── CLAUDE.md                # Claude Code rules
├── SKILL.md                 # Antigravity skill definition
└── README.md
```

### Generated at runtime (per project)

```
.ai-memory/
├── repo-map.txt              # Ultra-compressed directory tree
├── optimizer-stats.json      # Session history & cumulative savings
├── state.md                  # AI memory checklist (tasks, decisions, milestones)
├── token-memory-graph.json   # Machine-readable graph for AI agents (new!)
├── scripts/                  # Init script copy
└── .watch.pid / .watch.log   # Watcher daemon files
```

---

## 🤝 Contributing

PRs and issues are welcome at [github.com/Basharlouzon/Token-save---optimizer](https://github.com/Basharlouzon/Token-save---optimizer).

### Quick dev setup

```bash
git clone https://github.com/Basharlouzon/Token-save---optimizer.git
cd Token-save---optimizer
bash bin/tokenso install      # test the installer
bash bin/tokenso run          # test the mindmap
```

---

## 📄 License

MIT License — free to use, modify, and distribute. See [LICENSE](LICENSE).
