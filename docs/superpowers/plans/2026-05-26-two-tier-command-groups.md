# Two-Tier Command Groups Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure Tokenso's CLI surface into a daily-tier / management-tier split so users only need to remember 5 commands for daily work.

**Architecture:** Add three functions (`show_help`, `show_config_help`, `run_smart_status`) and a `run_config` dispatcher to `bin/tokenso` immediately before the existing router; replace the router with an updated version that adds a `config` top-level subcommand, backward-compat discovery hints on old management commands, and rewires the no-args and help routes.

**Tech Stack:** Bash. No external dependencies added.

---

## File Map

| File | Change |
|---|---|
| `bin/tokenso` | Add 3 functions + `run_config`; replace router block (lines 3204–3258) |
| `tests/test_ux.sh` | New — bash test runner for the new UX surface |
| `README.md` | Update command table to show two-tier structure |

---

## Task 1: Test Harness

**Files:**
- Create: `tests/test_ux.sh`

- [ ] **Step 1: Create the test file with assert helpers and five failing test cases**

```bash
#!/bin/bash
# tests/test_ux.sh — smoke tests for two-tier command groups
# Run from repo root: bash tests/test_ux.sh

set -uo pipefail
PASS=0; FAIL=0
BIN="$(cd "$(dirname "$0")/.." && pwd)/bin/tokenso"
TMPDIR_TEST=$(mktemp -d)
trap 'rm -rf "$TMPDIR_TEST"' EXIT

assert_contains() {
    local desc="$1" output="$2" pattern="$3"
    if echo "$output" | grep -q "$pattern"; then
        echo "  PASS  $desc"
        PASS=$((PASS+1))
    else
        echo "  FAIL  $desc"
        echo "        expected pattern: $pattern"
        echo "        actual output snippet: $(echo "$output" | head -5)"
        FAIL=$((FAIL+1))
    fi
}

assert_not_contains() {
    local desc="$1" output="$2" pattern="$3"
    if ! echo "$output" | grep -q "$pattern"; then
        echo "  PASS  $desc"
        PASS=$((PASS+1))
    else
        echo "  FAIL  $desc"
        echo "        pattern should be absent: $pattern"
        FAIL=$((FAIL+1))
    fi
}

cd "$TMPDIR_TEST"

echo ""
echo "── tokenso UX tests ────────────────────────────────────"

# Test 1: help shows daily tier label
OUT=$("$BIN" help 2>&1 || true)
assert_contains    "help: shows DAILY COMMANDS heading"   "$OUT" "DAILY COMMANDS"

# Test 2: help does NOT dump the full management list inline
assert_not_contains "help: no 'config install' in main body" "$OUT" "config install"

# Test 3: help all shows old full dashboard (ASCII art banner)
OUT_ALL=$("$BIN" help all 2>&1 || true)
assert_contains    "help all: contains ASCII banner"      "$OUT_ALL" "TOKENSO\|tokenso\|Save Optimizer"

# Test 4: tokenso config (no subcommand) shows config help
OUT_CFG=$("$BIN" config 2>&1 || true)
assert_contains    "config: shows config subcommands"     "$OUT_CFG" "config install"

# Test 5: bare tokenso (no .ai-memory) shows compact not-initialized message
OUT_BARE=$("$BIN" 2>&1 || true)
assert_not_contains "bare tokenso: no ASCII art banner"   "$OUT_BARE" "╗"

echo ""
echo "── Results: $PASS passed, $FAIL failed ─────────────────"
[ $FAIL -eq 0 ] && exit 0 || exit 1
```

- [ ] **Step 2: Run tests to confirm they all fail**

```bash
bash tests/test_ux.sh
```

Expected: 5 failures (functions and routing not yet implemented).

- [ ] **Step 3: Commit the failing tests**

```bash
git add tests/test_ux.sh
git commit -m "test: add failing UX smoke tests for two-tier command groups"
```

---

## Task 2: `show_help` and `show_config_help`

**Files:**
- Modify: `bin/tokenso` — insert two functions before `# ─── ROUTER` at line 3204

- [ ] **Step 1: Open `bin/tokenso` and locate the router comment**

Find the line that reads exactly:
```
# ─── ROUTER ─────────────────────────────────────────────────────────────────
```
It is currently at line 3204. All new functions go immediately above it.

- [ ] **Step 2: Insert `show_help` and `show_config_help` above the router**

Add this block immediately before `# ─── ROUTER`:

```bash
# ─── TWO-TIER HELP ──────────────────────────────────────────────────────────
show_help() {
    echo ""
    echo -e "  ${BOLD}${BCYAN}tokenso${NC}  ${DIM}v$VERSION${NC}"
    echo ""
    echo -e "  ${BOLD}── DAILY COMMANDS ───────────────────────────────────${NC}"
    echo -e "  ${CYAN}tokenso${NC}                Smart status — tokens saved, next action"
    echo -e "  ${CYAN}tokenso save \"note\"${NC}    Save stats, refresh map, update state"
    echo -e "  ${CYAN}tokenso search <q>${NC}    Zero-waste codebase search"
    echo -e "  ${CYAN}tokenso state${NC}          View and edit AI memory"
    echo -e "  ${CYAN}tokenso stats${NC}          Full report  ${DIM}(--html / --json / --csv)${NC}"
    echo ""
    echo -e "  ${DIM}tokenso config <cmd>   manage install / watch / update / doctor / clean / reset${NC}"
    echo -e "  ${DIM}tokenso help all       show all commands${NC}"
    echo ""
}

show_config_help() {
    echo ""
    echo -e "  ${BOLD}── tokenso config ───────────────────────────────────${NC}"
    echo -e "  ${CYAN}tokenso config install${NC}   Project setup wizard"
    echo -e "  ${CYAN}tokenso config watch${NC}     Background auto-save  ${DIM}(start/stop/status/log)${NC}"
    echo -e "  ${CYAN}tokenso config update${NC}    Self-update from GitHub"
    echo -e "  ${CYAN}tokenso config doctor${NC}    Environment diagnostics"
    echo -e "  ${CYAN}tokenso config clean${NC}     Wipe cached optimizer files"
    echo -e "  ${CYAN}tokenso config reset${NC}     Clear cumulative stats history"
    echo ""
    echo -e "  ${DIM}tokenso help all   for full command reference${NC}"
    echo ""
}
```

- [ ] **Step 3: Run tests — expect Tests 1, 2, 4 to pass; 3 and 5 still fail**

```bash
bash tests/test_ux.sh
```

Expected: PASS on tests 1, 2, 4. FAIL on tests 3 and 5 (router not updated yet).

- [ ] **Step 4: Commit**

```bash
git add bin/tokenso
git commit -m "feat: add show_help and show_config_help for two-tier UX"
```

---

## Task 3: `run_smart_status`

**Files:**
- Modify: `bin/tokenso` — insert function before `# ─── ROUTER`

- [ ] **Step 1: Insert `run_smart_status` in the new two-tier help block (after `show_config_help`)**

Add this function immediately after `show_config_help` and before `# ─── ROUTER`:

```bash
run_smart_status() {
    if [ ! -d ".ai-memory" ]; then
        echo ""
        echo -e "  ${YELLOW}⚠  Not initialized.${NC}  Run ${CYAN}tokenso config install${NC} to get started."
        echo ""
        echo -e "  ${DIM}tokenso help for commands${NC}"
        echo ""
        return
    fi

    load_or_init_stats

    local file_list
    file_list=$(list_source_files)
    local raw_words=0
    [ -n "$file_list" ] && raw_words=$(echo "$file_list" | tr '\n' '\0' | xargs -0 wc -w 2>/dev/null | tail -1 | awk '{print $1}')
    local map_words=0
    [ -f ".ai-memory/repo-map.txt" ] && map_words=$(wc -w < ".ai-memory/repo-map.txt")
    local raw_tokens=$(( raw_words * 13 / 10 ))
    local map_tokens=$(( map_words * 13 / 10 ))
    local saved_tokens=$(( raw_tokens - map_tokens ))
    [ $saved_tokens -lt 0 ] && saved_tokens=0
    local pct=0
    [ $raw_tokens -gt 0 ] && pct=$(( saved_tokens * 100 / raw_tokens ))
    local cost_saved
    cost_saved=$(cost_usd "$saved_tokens")
    local cost_cum
    cost_cum=$(cost_usd "$CUMULATIVE_SAVED")

    local next_action=""
    if [ -f ".ai-memory/state.md" ]; then
        next_action=$(grep "^- \[ \]" ".ai-memory/state.md" 2>/dev/null | head -1 | sed 's/^- \[ \] //')
    fi
    [ -z "$next_action" ] && next_action="Run tokenso save to record this session"

    local project
    project=$(basename "$(pwd)")

    echo ""
    echo -e "  ${BOLD}${BCYAN}tokenso${NC}  ${CYAN}$project${NC}  ${DIM}v$VERSION${NC}          ${DIM}session $SESSIONS${NC}"
    echo ""
    printf "  %-18s %s\n" "Saved per session" "$(echo -e "${YELLOW}$(fmt_num $saved_tokens) tokens${NC}    ${GREEN}\$$cost_saved${NC}   $(draw_bar $pct)  ${pct}%")"
    printf "  %-18s %s\n" "All-time" "$(echo -e "${BGREEN}$(fmt_num $CUMULATIVE_SAVED) tokens${NC}    ${GREEN}\$$cost_cum${NC}   ${DIM}$SESSIONS sessions${NC}")"
    echo ""
    echo -e "  ${BOLD}Next${NC}  ${CYAN}→${NC}  $next_action"
    echo ""
    echo -e "  ${DIM}tokenso stats for full report · tokenso help for commands${NC}"
    echo ""
}
```

- [ ] **Step 2: Run tests — all 5 should still have the same result as before (router not wired yet)**

```bash
bash tests/test_ux.sh
```

Expected: Tests 1, 2, 4 still pass. Tests 3 and 5 still fail.

- [ ] **Step 3: Commit**

```bash
git add bin/tokenso
git commit -m "feat: add run_smart_status compact default output"
```

---

## Task 4: Replace the Router

**Files:**
- Modify: `bin/tokenso` — replace the `# ─── ROUTER` block (lines 3204–3258)

- [ ] **Step 1: Replace the entire router block**

Find and replace the block from `# ─── ROUTER ─────────────────────────────────────────────────────────────────` through the final `esac` with:

```bash
# ─── ROUTER ─────────────────────────────────────────────────────────────────
case "$1" in
    run)
        shift; run_gui "$@" ;;
    save)
        shift; run_save "$@" ;;
    search)
        shift; run_search "$@" ;;
    stats)
        shift; run_stats "$@" ;;
    state)
        shift; run_state "$@" ;;
    map)
        shift; run_map "$@" ;;
    smart)
        shift; run_smart "$@" ;;
    config)
        shift
        case "$1" in
            install)  shift; run_install "$@" ;;
            watch)    shift; run_watch "$@" ;;
            update)   run_update ;;
            doctor)   run_doctor ;;
            clean)    shift; run_clean "$@" ;;
            reset)    run_reset ;;
            *)        show_config_help ;;
        esac ;;
    # Backward-compat: old management commands still work, surface discovery hint
    install)
        echo -e "${DIM}Tip: also available as 'tokenso config install'${NC}"
        shift; run_install "$@" ;;
    watch)
        echo -e "${DIM}Tip: also available as 'tokenso config watch'${NC}"
        shift; run_watch "$@" ;;
    update)
        echo -e "${DIM}Tip: also available as 'tokenso config update'${NC}"
        run_update ;;
    doctor)
        echo -e "${DIM}Tip: also available as 'tokenso config doctor'${NC}"
        run_doctor ;;
    clean)
        echo -e "${DIM}Tip: also available as 'tokenso config clean'${NC}"
        shift; run_clean "$@" ;;
    reset)
        echo -e "${DIM}Tip: also available as 'tokenso config reset'${NC}"
        run_reset ;;
    status)           run_status ;;
    --version|-v)     show_version ;;
    help|--help|-h)
        if [ "${2:-}" = "all" ]; then
            show_dashboard
        else
            show_help
        fi ;;
    "")               run_smart_status ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        show_help
        exit 1 ;;
esac
```

- [ ] **Step 2: Run all 5 tests — expect all to pass**

```bash
bash tests/test_ux.sh
```

Expected output:
```
── tokenso UX tests ────────────────────────────────────
  PASS  help: shows DAILY COMMANDS heading
  PASS  help: no 'config install' in main body
  PASS  help all: contains ASCII banner
  PASS  config: shows config subcommands
  PASS  bare tokenso: no ASCII art banner

── Results: 5 passed, 0 failed ─────────────────
```

- [ ] **Step 3: Smoke test manually**

```bash
./bin/tokenso help
./bin/tokenso help all
./bin/tokenso config
./bin/tokenso --version
```

Verify:
- `help` shows 5 commands + hint line, no ASCII art
- `help all` shows full old dashboard with ASCII banner
- `config` shows 6 management subcommands
- `--version` still prints version string

- [ ] **Step 4: Commit**

```bash
git add bin/tokenso
git commit -m "feat: wire two-tier router with config subcommand and backward-compat aliases"
```

---

## Task 5: Update README

**Files:**
- Modify: `README.md` — update the `## 🛠 All Commands` table

- [ ] **Step 1: Replace the commands table under `## 🛠 All Commands`**

Find the section that starts with `## 🛠 All Commands` and replace the table with:

```markdown
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
| `tokenso run` | Interactive cognitive mindmap & stats save |
| `tokenso map` | Colorized repository structure tree |
| `tokenso smart` | AI agent autopilot (auto-init, refresh, save, diagnose) |
| `tokenso smart --json` | Same as above, JSON output |
| `tokenso status` | Quick one-line project health check |
| `tokenso help` | Show daily commands |
| `tokenso help all` | Show all commands |
| `tokenso --version` | Show version |

> **Backward compatibility:** All old commands (`tokenso install`, `tokenso watch`, etc.) continue to work and now print a one-line hint pointing to the `config` namespace.
```

- [ ] **Step 2: Run tests one final time to confirm nothing regressed**

```bash
bash tests/test_ux.sh
```

Expected: 5 passed, 0 failed.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: update command reference for two-tier CLI structure"
```

---

## Self-Review

**Spec coverage:**
- ✅ Daily tier (5 commands) — Task 2 + Task 4
- ✅ Management tier under `tokenso config` — Task 2 + Task 4
- ✅ Backward-compat aliases with hint — Task 4
- ✅ `help` shows daily only; `help all` shows everything — Task 2 + Task 4
- ✅ Compact default output (`run_smart_status`) — Task 3
- ✅ "Next →" from state.md pending actions — Task 3
- ✅ README updated — Task 5

**Placeholder scan:** No TBDs, no "implement later", all code blocks are complete.

**Type consistency:** `show_help`, `show_config_help`, `run_smart_status`, `show_config_help` — names are consistent across all tasks. Router calls match function names exactly.
