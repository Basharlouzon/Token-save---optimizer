---
name: tokenso
description: Use when you want to minimize token waste, intelligently search files without overflowing the context, and refresh memory across agents (Claude Code, Cline, Roo, Kilo, Gemini CLI, Antigravity) using Tokenso. Enhanced with token budgets, auto-map refresh, batch search, and improved state management.
risk: low
source: local
---

# Tokenso — Context Optimizer & Token Saver

This skill prevents context window bloat, eliminates token waste, and stops agents from duplicating efforts or spinning in circles.

As an AI agent, strictly follow these rules when this skill is active or when operating in a repository with `.ai-memory` initialized by Tokenso.

## 1. The Search Diet (Zero-Waste Searching)

- **Do not read full files blindly**: Before using tools to read an entire file, check its size or use targeted search.
- **Find first, read second**: ALWAYS use semantic search, `grep`, or lightweight commands (`rg -l`) to find the *names* of files first.
- **Targeted viewing**: Once a file is identified, read *only the specific line ranges* you need. NEVER load a 2,000-line file into context just to read a single function.
- **Batch search patterns**: Combine multiple patterns into a single pass: `rg -n "pattern1|pattern2|pattern3"` instead of three separate searches.

## 2. Token Budget Awareness

Before any large operation:

1. **Estimate context cost.** A 500-line file ≈ 2,000 tokens. A `find` on a large repo ≈ 5,000+ tokens.
2. **Warn if approaching limits.** If you've read >50% of context, note: "Context is getting heavy — compressing before continuing."
3. **Prefer compressed sources.** Read `.ai-memory/repo-map.txt` (tiny) over `tree` or `find` (expensive).

## 3. Smart Initialization

- **Use the Repo Map**: Run `tokenso map` (preferred) or `bash .ai-memory/scripts/init-smart-search.sh .` from the project root.
- **Read the Map**: This generates an ultra-compressed tree at `.ai-memory/repo-map.txt`. Read this tiny file instead of manually exploring.
- **Auto-refresh stale maps**: If the map is older than recently modified source files, suggest `tokenso save` to refresh.

## 4. The Memory Refresh Protocol (Prevent Duplication & Looping)

- **Check State**: Before significant decisions, ALWAYS read `.ai-memory/state.md` (or run `tokenso state`).
- **Write State**: After milestones or repeated actions, compress findings into `.ai-memory/state.md` via `tokenso save "[note]"`.
- **Context Pruning**: After writing state, acknowledge you are offloading raw context. If you detect a loop, **STOP**, update memory, and ask for clarification.

### `state.md` format

```markdown
# AI Memory State

## Completed Tasks
- [x] Initialized Tokenso smart search memory
- [x] Implemented auth flow with JWT refresh tokens

## Next Actions
- [ ] Wire `/api/logout` to invalidate refresh tokens
- [ ] Add e2e test for the expired-token redirect

## Blocked
- [ ] Waiting on API key from ops team

## Decisions
! Chose SQLite over PostgreSQL for local-first storage.
! Refresh tokens live in httpOnly cookies, not localStorage.

## Key Context & Architecture
! `useAuth()` is the single source of truth — do not read `req.user` directly.
```

## 5. Context Compression Checklist

When context feels heavy:

1. Identify key facts, decisions, and remaining tasks.
2. Write to `state.md` using the format above.
3. Run `tokenso save --silent` to update stats.
4. Note: "Compressed context into state.md — previous raw details offloaded."

## 6. Cross-Agent Compatibility

Inject these rules into other agents' configs:

```bash
bash scripts/apply-cross-rules.sh .            # current project
bash scripts/apply-cross-rules.sh ../other-app # different project
```

Supported: Claude Code, Cline, Roo, Kilo, Gemini CLI, Open Code, Aider, Continue.dev, Cursor, Windsurf, Void, Zed, PearAI, GitHub Copilot, Amazon Q, Augment Code.

## 7. Stop Duplication

If you find yourself in a loop:

1. **STOP** immediately.
2. Update `.ai-memory/state.md` with what you've tried and why it failed.
3. Ask the user for clarification before continuing.

## Output Format

When updating memory or pruning context:

```
✓ Tokenso: condensed insights into .ai-memory/state.md and pruned immediate context.
```
