# Tokenso Optimizer

Prevent context window bloat, eliminate token waste, and stop agents from duplicating efforts. Use when operating in any repository with `.ai-memory` initialized by Tokenso (`tokenso install`).

## 1. The Search Diet (Zero-Waste Searching)

- **Do not read full files blindly.** Check file size first (`wc -l file`). Use targeted search before reading.
- **Find first, read second.** Use `rg -l`, `grep -rl`, or `tokenso search <query>` to locate files before reading them.
- **Targeted viewing.** Read only specific line ranges. NEVER load a 2,000-line file to read one function.
- **Batch search patterns.** Combine multiple patterns: `rg -n "pattern1|pattern2|pattern3"` instead of sequential searches.
- **Use `tokenso search`.** It performs fuzzy path matching on `.ai-memory/repo-map.txt` plus a source-code snippet scan capped at 15 matches — ideal for zero-waste lookups.

## 2. Token Budget Awareness

Tokenso uses a fixed cost baseline of **$3.00 per 1M tokens** (Claude Sonnet, configurable in `.ai-memory/optimizer-stats.json`).

Before any large operation:

1. **Estimate context cost.** Token count is calculated as `words × 13 / 10` (inside `run_save()`). A 500-line file ≈ 2,000 tokens.
2. **Warn if approaching limits.** If you've read >50% of context, explicitly note: "Context is getting heavy — compressing before continuing."
3. **Prefer compressed sources.** Read `.ai-memory/repo-map.txt` (~20 lines) instead of running `tree` or `find`.

## 3. Smart Initialization

- **Use the Repo Map.** Run `tokenso map` (preferred) or `bash .ai-memory/scripts/init-smart-search.sh .` from the project root.
- **Auto-refresh stale maps.** Compare `.ai-memory/repo-map.txt` mtime vs recent file changes. If stale, suggest `tokenso save`.
- **Map generation uses `tree` with fallback to `find`.** Both paths share the same exclusion regex (defined at `bin/tokenso:92-93`):

```
EXCLUDE_FILE_PATTERN='\.(png|jpg|jpeg|gif|ico|pdf|zip|gz|tar|mp4|mp3|woff|woff2|ttf|eot|map|lock|db|exe|dll|so|dylib|class|jar|apk|ipa|bundle)$'
EXCLUDE_DIR_PATTERN='(^|/)(\.ai-memory|\.git|node_modules|build|dist|\.dart_tool|Pods|\.gradle|\.venv|venv|__pycache__|\.idea|\.vscode|\.expo|\.next|\.nuxt|out|coverage|\.nyc_output|target|\.cargo)(/|$)'
```

## 4. The Memory Refresh Protocol

- **Check State.** Before significant decisions, read `.ai-memory/state.md` (or run `tokenso state`).
- **Write State.** After milestones, run `tokenso save "note"` or `tokenso save -m "note"`. The `--silent` (`-s`) flag suppresses output.
- **Auto-install.** If `.ai-memory/` doesn't exist when `tokenso save` runs, it offers to run `tokenso install` automatically.
- **Context Pruning.** After writing state, acknowledge offloading raw context. If looping, STOP, update state, ask for clarification.

### Enhanced `state.md` Format

```markdown
# AI Memory State

## Completed Tasks
- [x] Initialized Tokenso smart search memory

## Next Actions
- [ ] Wire `/api/logout` to invalidate refresh tokens

## Blocked
- [ ] Waiting on API key from ops team

## Decisions
! Chose SQLite over PostgreSQL for local-first storage.
! Refresh tokens live in httpOnly cookies, not localStorage.

## Key Context & Architecture
! `useAuth()` is the single source of truth.
```

## 5. Context Compression Checklist

1. Identify key facts, decisions, and remaining tasks.
2. Write to `state.md` using the format above.
3. Run `tokenso save --silent` to update stats without verbose output.
4. Note: "Compressed context into state.md — previous raw details offloaded."

## 6. Stats & Tracking

Stats live in `.ai-memory/optimizer-stats.json`:

```json
{
  "schema": 1,
  "version": "2.2.0",
  "installed": "2026-05-17",
  "sessions": 12,
  "cumulative_saved": 274693,
  "last_run": "2026-05-17",
  "history": [{"date": "2026-05-17", "tokens_saved": 45000}]
}
```

- `tokenso stats` — terminal dashboard with session/all-time stats and sparkline.
- `tokenso stats --html` — glassmorphic HTML dashboard with SVG charts.
- `tokenso stats --json` / `--csv` — export formats.
- `tokenso reset` — clears cumulative stats but preserves install date.
- `tokenso clean` — wipes all of `.ai-memory/` (repo map, stats, state, scripts). Interactive confirmation required; config rules (`.cursorrules`, `.kilorules`, etc.) are NOT touched.

JSON parsing prefers `jq` with a grep/awk fallback for the 4 flat fields (`installed`, `sessions`, `cumulative_saved`, `history`). USD math prefers `bc` with `awk` fallback.

## 7. Cross-Agent Compatibility

```bash
bash scripts/apply-cross-rules.sh .            # current project
bash scripts/apply-cross-rules.sh ../other-app # different project
tokenso install                                # interactive wizard (16 tools)
```

Rules use versioned markers (`MARKER_VERSION="v1"`) so re-running safely updates. Supported: Claude Code, Cline, Roo, Kilo, Gemini CLI, Open Code, Aider, Continue.dev, Cursor, Windsurf, Void, Zed, PearAI, GitHub Copilot, Amazon Q, Antigravity.

## 8. Stop Duplication

If looping:

1. **STOP** immediately.
2. Update `.ai-memory/state.md` with what you tried and why it failed.
3. Ask the user for clarification.

## Output Format

```
✓ Tokenso: condensed insights into .ai-memory/state.md and pruned immediate context.
```
