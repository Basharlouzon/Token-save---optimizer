# ADR-0010: Token Budget Gate — Cap Estimated Spend, Auto-Pause on Cross

**Status:** Accepted
**Date:** 2026-06-12
**Version target:** v3.9.0

## Context
Users want to run maximum-effort work (many subagents, deep exploration) but
cap the plan-token spend at a predictable ceiling. Tokenso cannot read
Anthropic's real meter, so it must enforce a budget from *estimated*
consumption observed by the existing hooks. Per ADR-0005 (honest telemetry),
the estimate must be labeled as an estimate, never as exact billing. Builds on
the ADR-0008 hooks and the ADR-0009 pause flag. Constraints: bash 3.2, no
daemons, zero cost while blocked, reuse the pause enforcement (no new gate).

## Decision
We will add `tokenso budget <N>|off` that stores a per-project token cap; the
existing `guard-read` hook accumulates an estimated `used` count per session
and, on crossing the cap, writes the ADR-0009 pause flag (hard stop). A warn
band at 80% surfaces in the statusline without blocking. `used` resets each
session via the SessionStart hook.

## Options Considered

### Option A — Estimate in guard-read hook + reuse pause flag (chosen)
| Dimension | Score | Note |
|-----------|-------|------|
| Token cost | Zero while blocked | Reuses ADR-0009 UserPromptSubmit gate |
| Bash portability | Good | Integer math + flag file; no new deps |
| Dependencies | None | python3 only for budget.json read/write, with sed fallback |
| Cross-tool reach | Claude Code only | Same as ADR-0008/0009 |
| Install surface | None | No new hooks; guard-read already wired |
| Migration cost | None | New optional .ai-memory/budget.json |
| Reversibility | High | `tokenso budget off` removes the cap |

**Pros:** No new enforcement surface; honest (labeled estimate); intuitive per-session cap; auto-warn before hard stop.
**Cons:** Estimate only — undercounts non-Read token use (model output, thinking); acceptable since reads dominate Tokenso's tracked savings.

### Option B — Separate budget-check hook on every PreToolUse
| Dimension | Score | Note |
|-----------|-------|------|
| Token cost | Zero while blocked | — |
| Bash portability | Good | — |
| Dependencies | None | — |
| Cross-tool reach | Claude Code only | — |
| Install surface | New hook entry | Another matcher on every tool call |
| Migration cost | Requires re-install | — |
| Reversibility | High | — |

**Pros:** Counts more tool types.
**Cons:** Extra hook latency on every call; more install surface; marginal gain since reads dominate. Rejected for complexity.

## Trade-off
A beats B because the read-guard already runs on the dominant token sink and
already has the file size in hand — folding the budget tally into it adds the
cap for free, with no extra hook latency or install step.

## Consequences
- Easier: launch high-effort runs with a hard, honest ceiling; warn band prevents surprise freezes.
- Harder: estimate undercounts model output tokens — documented, not hidden.
- Revisit when: per-day or dollar-denominated budgets are requested, or a real usage API becomes available.

## Action Items
- [x] `run_budget` + budget tally in `run_hook guard-read` + reset in `session-start`
- [x] Statusline budget display (warn band at 80%)
- [x] README + version bump to 3.9.0
- [x] Note in `.ai-memory/state.md`
