# ADR-0009: Pause Switch — Hard-Block Claude Code Usage Until Resumed

**Status:** Accepted
**Date:** 2026-06-12
**Version target:** v3.8.0

## Context
Users on metered Claude plans need a way to stop *all* token consumption in a
project on demand — e.g. to preserve remaining plan quota — and have it stay
stopped until explicitly re-enabled. CLAUDE.md rules cannot enforce this; only
harness hooks can. Builds on the ADR-0008 hooks infrastructure. Constraints:
bash 3.2, no daemons, zero cost while paused, trivially reversible.

## Decision
We will add `tokenso pause [reason]` / `tokenso resume`, backed by a
`.ai-memory/paused` flag file, enforced by a `tokenso hook gate` wired into
`UserPromptSubmit` (blocks prompts before any model call — zero tokens) and a
catch-all `PreToolUse` matcher (stops in-flight sessions).

## Options Considered

### Option A — Flag file + UserPromptSubmit/PreToolUse gate (chosen)
| Dimension | Score | Note |
|-----------|-------|------|
| Token cost | Zero while paused | UserPromptSubmit exit 2 blocks before the model is invoked |
| Bash portability | Good | Flag file test + exit code only |
| Dependencies | None | — |
| Cross-tool reach | Claude Code only | Same limitation as ADR-0008 |
| Install surface | None | Delivered via existing `tokenso claude install` |
| Migration cost | None | Re-running install adds the new hooks idempotently |
| Reversibility | High | `tokenso resume` deletes one file; uninstall removes hooks |

**Pros:** True hard stop; survives restarts; visible in statusline; one-command resume.
**Cons:** In-flight sessions see repeated blocked tool calls until the turn ends.

### Option B — Permission-mode manipulation (write `defaultMode: "plan"` etc. into settings)
| Dimension | Score | Note |
|-----------|-------|------|
| Token cost | Low but not zero | Plan mode still reads files and burns tokens |
| Bash portability | Good | — |
| Dependencies | python3 | Settings rewrite on every toggle |
| Cross-tool reach | Claude Code only | — |
| Install surface | None | — |
| Migration cost | None | — |
| Reversibility | Medium | Risk of clobbering the user's own permission config |

**Pros:** Uses native modes.
**Cons:** Does not actually stop usage — plan mode still consumes tokens; toggling rewrites user config.

## Trade-off
A beats B because the requirement is *no plan usage at all* until resumed; only
blocking at UserPromptSubmit achieves zero cost, and a flag file never touches
user-owned settings keys.

## Consequences
- Easier: instant, durable kill switch per project; visible pause state everywhere.
- Harder: users must know `tokenso resume` (the block message says so every time).
- Revisit when: Claude Code adds a native usage-freeze API, or per-user global pause is requested (`~/.tokenso/paused`).

## Action Items
- [x] `run_pause`/`run_resume` + `gate` hook event in `bin/tokenso`
- [x] Add UserPromptSubmit + catch-all PreToolUse entries to `_claude_hooks_write`
- [x] Statusline + `tokenso claude status` show paused state
- [x] README + version bump to 3.8.0
