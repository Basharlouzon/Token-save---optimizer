# ADR-0008: Native Claude Code Hooks Integration

**Status:** Accepted
**Date:** 2026-06-12
**Version target:** v3.7.0

## Context
Tokenso currently saves tokens in Claude Code only *advisorily*: it injects rules
into `CLAUDE.md` and hopes the model follows them. Claude Code has a first-class
hooks system (`.claude/settings.json`) that lets external tools enforce behavior
at the harness level: inject context at SessionStart, gate tool calls in
PreToolUse, checkpoint at PreCompact, and render a statusline. Enforced behavior
beats requested behavior. Constraints: bash 3.2 compatible, no daemons, no hard
dependencies (python3 used with graceful fallback), single-file `bin/tokenso`,
must not clobber user's existing settings.

## Decision
We will add a `tokenso claude install|status|uninstall` command group that
merges Tokenso hooks (SessionStart context injection, PreToolUse Read guard,
PreCompact auto-save) and a statusline into the project's
`.claude/settings.json`, plus the hidden hook entry points they invoke.

## Options Considered

### Option A — Harness hooks via `.claude/settings.json` (chosen)
| Dimension | Score | Note |
|-----------|-------|------|
| Token cost | Low | SessionStart brief ~150t replaces ad-hoc exploration; Read guard prevents multi-k full-file reads |
| Bash portability | Good | Hooks are plain bash; JSON merge uses python3 with create-if-absent fallback |
| Dependencies | Optional | python3 only for merging into an *existing* settings.json |
| Cross-tool reach | Claude Code only | Other tools keep the CLAUDE.md rules path |
| Install surface | None | No install.sh change; opt-in per project |
| Migration cost | None | `.ai-memory/` schema untouched |
| Reversibility | High | `tokenso claude uninstall` removes only `tokenso`-owned entries |

**Pros:** Enforced, deterministic savings; zero reliance on model compliance; clean opt-in/out.
**Cons:** Claude Code–specific; JSON merge needs python3 when settings.json already exists.

### Option B — Strengthen CLAUDE.md rules + wrap analytics only
| Dimension | Score | Note |
|-----------|-------|------|
| Token cost | Medium | Rules cost ~400t per session and are frequently ignored under pressure |
| Bash portability | Good | Text injection only |
| Dependencies | None | — |
| Cross-tool reach | All 16+ tools | Same mechanism everywhere |
| Install surface | None | — |
| Migration cost | None | — |
| Reversibility | High | — |

**Pros:** Universal, simple.
**Cons:** Advisory only — the core weakness this ADR exists to fix; no compaction checkpointing; no live feedback.

## Trade-off
A beats B because the goal is *guaranteed* savings in Claude Code specifically,
and hooks are the only mechanism the harness actually enforces. B remains in
place for every other tool, so nothing is lost.

## Consequences
- Easier: sessions start primed (state + map stats) with zero exploration; large blind reads get redirected to symbol/range reads; state survives compaction automatically.
- Harder: one more integration surface to keep in sync with Claude Code's hook schema; uninstall must stay precise (only remove `tokenso`-owned hooks).
- Revisit when: Claude Code changes its hooks/statusline schema, or when other tools (Gemini CLI, Cline) ship comparable hook systems worth targeting.

## Action Items
- [x] `run_claude` command group + `tokenso hook <event>` + `tokenso statusline` in `bin/tokenso`
- [x] Update `README.md` badge + "What's new"
- [x] Bump version to 3.7.0 per `release-manager`
- [x] Note decision in `.ai-memory/state.md`
