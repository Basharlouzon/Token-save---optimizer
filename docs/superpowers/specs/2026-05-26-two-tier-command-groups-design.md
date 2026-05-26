# Tokenso Two-Tier Command Groups

**Date:** 2026-05-26  
**Status:** Approved  
**Goal:** Reduce daily cognitive load by collapsing 20+ commands into a clear primary/management split.

---

## Problem

Tokenso has 20+ commands. Users forget which one to reach for. The default `tokenso` (no args) dumps a 30-line dashboard when most sessions just need a quick status check. `save` and `smart` overlap in purpose, adding to the confusion.

---

## Solution: Two-Tier Command Surface

### Daily Tier (shown in default `--help`)

| Command | Description |
|---|---|
| `tokenso` | Compact 4-6 line smart status; auto-refreshes map |
| `tokenso save "note"` | Save stats + update state + refresh map |
| `tokenso search <query>` | Zero-waste codebase search |
| `tokenso state` | View/edit AI memory state |
| `tokenso stats` | Full dashboard; `--html`, `--json`, `--csv` unchanged |

### Management Tier (under `tokenso config`, hidden from default `--help`)

| Command | Was |
|---|---|
| `tokenso config install` | `tokenso install` |
| `tokenso config watch <start\|stop\|status\|log>` | `tokenso watch ...` |
| `tokenso config update` | `tokenso update` |
| `tokenso config doctor` | `tokenso doctor` |
| `tokenso config clean` | `tokenso clean` |
| `tokenso config reset` | `tokenso reset` |

### Help

| Command | Shows |
|---|---|
| `tokenso help` | Daily tier only |
| `tokenso help all` | All commands including management tier |
| `tokenso --version` | Version string (unchanged) |

---

## New Default Output (`tokenso` with no args)

Replaces the 30-line dashboard with a compact 4-6 line status:

```
 tokenso  claudememory  v2.3.0          session 14 · 12 files changed

  Saved today      146,960 tokens    $0.44   ████████████████████░░░  99%
  All-time         1,763,520 tokens   $5.29   12 sessions

  Next  →  Read .ai-memory/state.md before starting work

  tokenso stats for full report · tokenso help for commands
```

- **"Next →"** is pulled from the existing `smart` suggestions logic
- No animations, no ASCII art in this path
- Bottom line surfaces discovery without cluttering the status

---

## Architecture

All changes are contained in `bin/tokenso`. No new files. No data model changes.

### Three edits

**1. Router (`~line 3204`)** — add `config` case; keep old top-level commands as backward-compat aliases that print a one-line hint:

```bash
config)
    shift
    case "$1" in
        install) run_install ;;
        watch)   shift; run_watch "$@" ;;
        update)  run_update ;;
        doctor)  run_doctor ;;
        clean)   run_clean ;;
        reset)   run_reset ;;
        *)       show_config_help ;;
    esac ;;
install)
    echo "Tip: also available as 'tokenso config install'"
    run_install ;;
watch)
    echo "Tip: also available as 'tokenso config watch'"
    shift; run_watch "$@" ;;
# same pattern for update, doctor, clean, reset
```

**2. New `run_smart_status` function** — compact output handler; calls existing smart logic internally; replaces `show_dashboard` as the default (no-args) target. `show_dashboard` stays intact.

**3. Updated help functions:**
- `show_help` — new; shows daily tier only (5 commands + one-liner hint for `help all`)
- `show_help_all` — delegates to existing `show_dashboard`
- Router: `""` → `run_smart_status`, `help|--help|-h` → `show_help`

### No changes to

- `.ai-memory/` directory structure
- `optimizer-stats.json` schema
- `tokenso-dashboard.html`
- Search logic, state format, AI tool config injection
- `tokenso run` (mindmap), `tokenso smart`, `tokenso map`

---

## Backward Compatibility

Every existing command continues to work. Old commands print a single discovery hint pointing to the `config` namespace. No scripts break. No CI pipelines break.

---

## Out of Scope

- Short aliases (`t`, `tokenso s`)
- REPL / interactive mode
- Changes to the HTML dashboard
- Refactoring the bash script into modules
