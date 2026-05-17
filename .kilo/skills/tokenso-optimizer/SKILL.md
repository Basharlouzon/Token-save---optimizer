# Tokenso Optimizer

Prevent context window bloat, eliminate token waste, and stop agents from duplicating efforts or spinning in circles. Use when operating in any repository with `.ai-memory` initialized by Tokenso.

## 1. The Search Diet (Zero-Waste Searching)

- **Do not read full files blindly.** Before using tools to read a file, check its size or use targeted search.
- **Find first, read second.** ALWAYS use semantic search, `grep`, or lightweight commands (`rg -l`) to find file names first.
- **Targeted viewing.** Once identified, read only the specific line ranges you need. NEVER load a 2,000-line file into context just to read a single function.
- **Batch search patterns.** When searching for multiple patterns, combine them into a single pass: `rg -n "pattern1|pattern2|pattern3" --type-add 'src:*.{ts,tsx,js,py,go,rs}' -t src` instead of three separate searches.

## 2. Token Budget Awareness

Before any large operation (reading multiple files, generating code, running searches):

1. **Estimate context cost.** A 500-line file ≈ 2,000 tokens. A `find` on a large repo ≈ 5,000+ tokens.
2. **Warn if approaching limits.** If you've already read >50% of a typical context window, explicitly note: "Context is getting heavy — compressing before continuing."
3. **Prefer compressed sources.** Always read `.ai-memory/repo-map.txt` (tiny) over running `tree` or `find` (expensive).

## 3. Smart Initialization

- **Use the Repo Map.** If you need to understand the project structure, do not run `ls -R` or `find`. Run `tokenso map` (preferred) or `bash .ai-memory/scripts/init-smart-search.sh .` from the project root.
- **Read the Map.** This generates an ultra-compressed tree at `.ai-memory/repo-map.txt`. Read this instead of manually exploring.
- **Auto-refresh stale maps.** If `.ai-memory/repo-map.txt` is older than the most recently modified source file, suggest refreshing: "The repo map appears stale — run `tokenso save` to refresh it."

## 4. The Memory Refresh Protocol

- **Check State.** Before making significant decisions or writing features, ALWAYS read `.ai-memory/state.md` (or run `tokenso state`).
- **Write State.** After completing a milestone, fixing a bug, or taking multiple steps that bloat context, compress findings into `.ai-memory/state.md` via `tokenso save "[note]"`.
- **Context Pruning.** After writing state, acknowledge you are offloading raw context and relying on compressed memory. If you detect a loop, STOP, update state, and ask for clarification.

### Enhanced `state.md` Format

```markdown
# AI Memory State

## Completed Tasks
- [x] Initialized Tokenso smart search memory

## Next Actions
- [ ] Wire the remaining endpoint

## Blocked
- [ ] Waiting on API key from ops team

## Decisions
! Chose SQLite over PostgreSQL for local-first storage (simpler deploy).
! Refresh tokens live in httpOnly cookies, not localStorage.

## Key Context & Architecture
! `useAuth()` is the single source of truth — do not read `req.user` directly.
```

## 5. Context Compression Checklist

When context feels heavy (repeated file reads, long conversations):

1. Identify the key facts, decisions, and remaining tasks from the conversation.
2. Write them to `state.md` using the format above.
3. Run `tokenso save --silent` to update stats.
4. Explicitly note: "Compressed context into state.md — previous raw details are offloaded."

## 6. Cross-Agent Compatibility

Inject these memory-saving rules into other agents' configs:

```bash
bash scripts/apply-cross-rules.sh .            # current project
bash scripts/apply-cross-rules.sh ../other-app # different project
```

Supported: Claude Code, Cline, Roo, Kilo, Gemini CLI, Open Code, Aider, Continue.dev, Cursor, Windsurf, Void, Zed, PearAI, GitHub Copilot, Amazon Q.

## 7. Stop Duplication

If you find yourself in a loop or re-reading the same files:

1. **STOP** immediately.
2. Update `.ai-memory/state.md` with what you've tried and why it failed.
3. Ask the user for clarification before continuing.

## Output Format

When updating memory or pruning context:

```
✓ Tokenso: condensed insights into .ai-memory/state.md and pruned immediate context.
```
