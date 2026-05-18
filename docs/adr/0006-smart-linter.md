# ADR-0006: `tokenso smart` as a health linter

**Status:** Accepted
**Date:** 2026-05-18
**Version target:** v2.8.0

## Context

`tokenso smart` was already the entry point agents call at session start. It did initialization, refreshed stale maps, and saved stats — but it was passive about *content rot*. The user's own `state.md` ended up with:
- A stray `x` glued to the line-1 heading (`x# AI Memory State`).
- Leftover test-milestone lines (`! test`, `! tes`).

These are silent failure modes: nothing crashes, but every agent that reads the file processes garbage and either propagates the noise into responses or silently lowers its trust in the file. Same class of problem for an empty `symbol-map.txt` (extractor failed and you don't notice).

Turning `tokenso smart` into a health linter — and adding a `--fix` mode for the safe subset — closes the loop without adding a new command.

## Decision

Extend `run_smart` with a "STEP 6.5: HEALTH LINTER" block that runs after diagnostics and before suggestions. Findings go into the existing `issues[]` channel, so existing parsers and the dashboard get them for free. A `--fix` flag auto-applies the safe cleanups (only ones with a clear inverse rule).

Checks shipped in v2.8.0:

1. **`state.md` line 1 must be a heading.** Otherwise: warn, and with `--fix` either strip the garbage prefix mid-line (preserving the heading) or drop the line.
2. **Low-signal milestone lines** matching `^! (test|tes|tmp|temp|foo|bar|baz|xxx|debug|todo|asdf|qwer)$`. Warn + `--fix` removes them.
3. **Consecutive-duplicate milestones.** Warn + `--fix` de-duplicates.
4. **Bloated state.md** (> 200 lines). Warn only — compaction needs human judgment.
5. **`symbol-map.txt` exists but is empty** (extractor failure). Warn only.
6. **All-estimated trust gap.** If ≥ 5 sessions but 0 `tokenso wrap` sessions, nudge to wrap one.
7. **Orphan session manifests.** If > 100 in `.ai-memory/sessions/`, suggest pruning.

Any finding adds a follow-up suggestion: *"Re-run `tokenso smart --fix` to auto-apply safe cleanups."*

## Options Considered

### Option A — Extend `run_smart` with a linter pass + opt-in `--fix` (chosen)
| Dimension | Score | Note |
|-----------|-------|------|
| Token cost | None | Output joins existing channels |
| Bash portability | High | awk/grep/wc only |
| Cross-tool reach | Full | Already injected as the start-of-session command |
| Install surface | None | No new command, no schema changes |
| Migration cost | Zero | Pure additive |
| Reversibility | High | `--fix` only does invertible transforms; un-rotted file is the inverse |
| Discoverability | High | Agents already run `tokenso smart` |

**Pros:** Maximum reach (every session sees it), zero new surface. Opt-in `--fix` is conservative.
**Cons:** Coupling the linter to `smart` means the report grows. Mitigated by surfacing through the existing `issues[]` array, not a new section.

### Option B — Separate `tokenso doctor --lint` subcommand
**Pros:** Cleaner separation; `doctor` is already a diagnostic command.
**Cons:** Lower discoverability — `doctor` is run rarely; `smart` is run every session. Defeats the purpose.

### Option C — Background hook (run linter from the watcher)
**Pros:** Continuous.
**Cons:** Modifies files in the background; surprising. We want user/agent awareness before any cleanup.

## Trade-off

Option A wins because the linter's whole point is to surface rot *at the moment the agent is reading these files*. Pinning it to the session-start command guarantees that. Option B is too quiet; Option C is too noisy.

## Consequences

- Easier: rot can no longer build up unnoticed. New users get a self-healing system. Existing rotted files (like ours) get cleaned with a one-liner.
- Harder: every new lint check needs a tested fix path. We accept that — `--fix` is opt-in.
- Revisit when:
  - We find unsafe edge cases in `--fix` (e.g. multi-byte chars in line 1) → strengthen the heading-strip awk.
  - The lint list grows past ~10 checks → maybe split into `--lint-state` / `--lint-maps` flags.

## Action Items
- [x] STEP 6.5 lint pass in `run_smart`.
- [x] `--fix` flag opt-in.
- [x] Checks 1-7 above.
- [x] Suggestion to re-run with `--fix` when any finding fires.
- [x] Bump VERSION 2.7.1 → 2.8.0.
- [ ] Future: lint-only mode `tokenso smart --lint` that skips stats save.
- [ ] Future: `tokenso sessions --prune --keep-days N` companion to check 7.
