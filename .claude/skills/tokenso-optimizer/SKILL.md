---
name: tokenso-optimizer
description: "Use when you want to minimize token waste, search files without overflowing context, and refresh memory across 16+ AI tools. Provides token budget awareness, auto-map refresh, batch search, and enhanced state management."
---

# Tokenso Optimizer

Prevent context window bloat, eliminate token waste, and stop agents from duplicating efforts. Use when operating in any repository with `.ai-memory` initialized by Tokenso (`tokenso install`).

## 1. The Search Diet (Zero-Waste Searching)

- **Do not read full files blindly.** Check file size first (`wc -l file`). Use targeted search before reading.
- **Find first, read second.** Use `rg -l`, `grep -rl`, or `tokenso search <query>` to locate files before reading them.
- **Targeted viewing.** Read only specific line ranges. NEVER load a 2,000-line file to read one function.
- **Batch search patterns.** Combine multiple patterns: `rg -n "pattern1|pattern2|pattern3"` instead of sequential searches.
- **Use `tokenso search`.** Fuzzy path matching on the repo map plus source-code snippet scan capped at 15 matches.

## 2. Token Budget Awareness

Tokenso uses **$3.00 per 1M tokens** (Claude Sonnet baseline, configurable in `.ai-memory/optimizer-stats.json`). Token count is calculated as `words × 13 / 10`.

Before large operations:

1. **Estimate cost.** A 500-line file ≈ 2,000 tokens.
2. **Warn if heavy.** If you've read >50% of context: "Context is getting heavy — compressing before continuing."
3. **Prefer compressed sources.** Read `.ai-memory/repo-map.txt` (~20 lines) instead of `tree` or `find`.

## 3. Smart Initialization

- **Use the Repo Map.** Run `tokenso map` (preferred) or `bash .ai-memory/scripts/init-smart-search.sh .`.
- **Auto-refresh stale maps.** If map mtime < recent file changes, suggest `tokenso save`.
- **Exclusions are shared** between `rg` and `find` paths (defined at `bin/tokenso:92-93`): excludes `.git`, `node_modules`, `build`, `dist`, binary files, images, lock files, and more.

## 4. The Memory Refresh Protocol

- **Check State.** Before significant decisions, read `.ai-memory/state.md` (or run `tokenso state`).
- **Write State.** `tokenso save "note"` or `tokenso save -m "note"`. Use `--silent` (`-s`) to suppress output.
- **Auto-install.** If `.ai-memory/` missing, `tokenso save` offers to run `tokenso install`.
- **Context Pruning.** After writing state, acknowledge offloading. If looping, STOP, update state, ask for help.

### Enhanced `state.md` Format

```markdown
# AI Memory State

## Completed Tasks
- [x] Initialized Tokenso smart search memory

## Next Actions
- [ ] Wire `/api/logout`

## Blocked
- [ ] Waiting on API key

## Decisions
! Chose SQLite over PostgreSQL.

## Key Context & Architecture
! `useAuth()` is the single source of truth.
```

## 5. Context Compression Checklist

1. Identify key facts, decisions, remaining tasks.
2. Write to `state.md` using the format above.
3. Run `tokenso save --silent`.
4. Note: "Compressed context into state.md."

## 6. Stats & Tracking

Stats in `.ai-memory/optimizer-stats.json`:

```json
{
  "schema": 1,
  "version": "2.2.0",
  "installed": "2026-05-17",
  "sessions": 12,
  "cumulative_saved": 274693,
  "history": [{"date": "2026-05-17", "tokens_saved": 45000}]
}
```

- `tokenso stats` — terminal dashboard with sparkline.
- `tokenso stats --html` — glassmorphic HTML dashboard.
- `tokenso stats --json` / `--csv` — export formats.
- `tokenso reset` — clear stats, keep install date.
- `tokenso clean` — wipe all `.ai-memory/` (interactive confirmation). Config rules NOT touched.

## 7. Cross-Agent Compatibility

```bash
bash scripts/apply-cross-rules.sh .   # all tools
tokenso install                       # interactive wizard (16 tools)
```

Versioned markers (`MARKER_VERSION="v1"`) for safe re-application.

## 8. Stop Duplication

If looping: STOP → update `state.md` with what failed → ask user for clarification.

## Output Format

```
✓ Tokenso: condensed insights into .ai-memory/state.md and pruned immediate context.
```
