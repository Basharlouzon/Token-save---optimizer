---
name: tokenso
description: Use when you want to minimize token waste, intelligently search files without overflowing the context, and refresh memory across agents (Claude Code, Cline, Roo, Kilo, Gemini CLI, Antigravity) using Tokenso. Enhanced with token budgets, auto-map refresh, batch search, and improved state management.
risk: low
source: local
---

# Tokenso — Context Optimizer & Token Saver

Prevent context window bloat, eliminate token waste, and stop agents from duplicating efforts. Follow these rules when this skill is active or when operating in a repository with `.ai-memory` initialized by Tokenso.

## 1. The Search Diet (Zero-Waste Searching)

- **Do not read full files blindly**: Check file size first. Use targeted search to find file names before reading.
- **Find first, read second**: ALWAYS use `rg -l`, `grep -rl`, or `tokenso search <query>` to locate files first.
- **Targeted viewing**: Read only specific line ranges. NEVER load a 2,000-line file to read one function.
- **Batch search patterns**: Combine patterns: `rg -n "pattern1|pattern2|pattern3"` instead of sequential searches.
- **Use `tokenso search`**: Fuzzy path matching on repo map + source snippet scan capped at 15 matches.

## 2. Token Budget Awareness

Tokenso calculates tokens as `words × 13 / 10`. Cost baseline: **$3.00/1M tokens** (Claude Sonnet).

1. **Estimate cost.** A 500-line file ≈ 2,000 tokens.
2. **Warn if heavy.** If >50% of context used: "Context is getting heavy — compressing before continuing."
3. **Prefer compressed sources.** Read `.ai-memory/repo-map.txt` (~20 lines) instead of `tree`/`find`.

## 3. Smart Initialization

- **Use the Repo Map**: Run `tokenso map` (preferred) or `bash .ai-memory/scripts/init-smart-search.sh .`.
- **Auto-refresh stale maps**: If map mtime < recent file changes, suggest `tokenso save`.
- **Exclusions are shared** between `rg` and `find` (defined in `bin/tokenso`): excludes `.git`, `node_modules`, `build`, `dist`, `.ai-memory`, binary files, images, lock files.

## 4. The Memory Refresh Protocol

- **Check State**: Before significant decisions, read `.ai-memory/state.md` (or run `tokenso state`).
- **Write State**: `tokenso save "note"` or `tokenso save -m "note"`. Use `--silent` (`-s`) to suppress output.
- **Auto-install**: If `.ai-memory/` is missing, `tokenso save` offers to run `tokenso install`.
- **Context Pruning**: After writing state, acknowledge offloading. If looping, STOP, update state, ask for help.

### `state.md` format

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

## 6. Cross-Agent Compatibility

```bash
bash scripts/apply-cross-rules.sh .            # current project
bash scripts/apply-cross-rules.sh ../other-app # different project
tokenso install                                # interactive wizard (16 tools)
```

Supported (16 + Antigravity global): Claude Code, Cline, Roo, Kilo, Gemini CLI, Open Code, Aider, Continue.dev, Cursor, Windsurf, Void, Zed, PearAI, GitHub Copilot, Amazon Q, Antigravity.

Rules use versioned markers (`MARKER_VERSION="v1"`) for safe re-application.

## 7. Stop Duplication

If looping: **STOP** → update `.ai-memory/state.md` with what failed → ask user for clarification.

## Output Format

```
✓ Tokenso: condensed insights into .ai-memory/state.md and pruned immediate context.
```
