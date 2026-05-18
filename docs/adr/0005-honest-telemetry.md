# ADR-0005: Honest telemetry via `tokenso wrap`

**Status:** Accepted
**Date:** 2026-05-18
**Version target:** v2.7.0

## Context

The dashboard's "Cumulative Tokens Saved" number is computed as `raw_tokens - map_tokens` — what the agent *would* have read if it gulped every source file vs the small repo-map. That assumes every agent reads every file, every session, which is fiction. The number is a story, not a measurement.

This matters because the whole product thesis ("agents will save tokens if we give them better tools") needs evidence. Without measurement, Tokenso is faith-based.

The hard problem: most modern agents run as IDE plugins (Cursor, Claude Code Desktop, VS Code Copilot) where there's no process to wrap. But many agents *also* expose a CLI mode (`claude -p`, `cursor-cli`, `aider`, `kilo`) and Claude in particular supports `--output-format stream-json` which emits every tool call as JSONL on stdout.

## Decision

Ship `tokenso wrap <cmd> [args...]` that spawns the agent as a subprocess and records what's observable per tier:

1. **Universal** (every wrapped command): session manifest at `.ai-memory/sessions/<id>.json` with start/end, cwd, exit code, duration, git tree delta (modified/added). Stdout+stderr tee'd to `.ai-memory/sessions/<id>.log`.
2. **Structured-output detection**: if args contain `--output-format stream-json` (or `=stream-json`/`json`), parse the log for Claude Code tool-call events. Use `jq` if available; `grep -c` fallback. Report exact Read/Search/Bash/Edit/Write counts and approximate bytes read from `tool_result` content lengths.
3. **Heuristic fallback** for plain CLIs: grep the log for `Reading X.ts`-style lines as a rough proxy.

Dashboard adds an "Observed Activity" panel (clearly tagged REAL) separate from the existing "Estimated" cards. Smart report keeps reporting estimated savings — they're not mutually exclusive, they answer different questions ("upper bound" vs "what happened today").

`tokenso sessions` lists the most recent 20 sessions in a terminal table.

## Options Considered

### Option A — `tokenso wrap` with tiered measurement (chosen)
| Dimension | Score | Note |
|-----------|-------|------|
| Token cost | None | Internal command |
| Bash portability | High | Pure bash + jq optional |
| Dependencies | Optional | `jq` preferred but grep-c fallback exists |
| Cross-tool reach | Medium | Works for any CLI agent; misses IDE/MCP-only agents (see Future) |
| Install surface | Small | New session directory + 2 commands |
| Migration cost | Zero | Additive; old metric stays |
| Reversibility | High | Delete `.ai-memory/sessions/` to reset |

**Pros:** Honest measurement where the user has a CLI agent. Composes with existing rules. Falls back gracefully.
**Cons:** Doesn't see Claude Code Desktop or IDE-only flows — those need a separate MCP-server approach.

### Option B — Ingest Claude Code's transcript logs (`~/.claude/projects/<hash>/<session>.jsonl`)
**Pros:** Works for Claude Code Desktop without any user-side wrapping.
**Cons:** Claude Code only. Log format can drift across releases. Privacy concerns reading user's whole transcript history.

### Option C — Hook injection: extend cross-tool rules with "log every Read to .ai-memory/observed.log"
**Pros:** Multi-agent.
**Cons:** Self-reporting again — agents skip logging under load. Doesn't actually fix the trust problem.

## Trade-off

Option A is the right *next* step because it gives honest data for the CLI usage pattern that's growing fastest (agent-as-tool, scripted automations, headless CI integration with `claude -p`). It's a clean foundation and doesn't preclude Option B or an MCP server (`tokenso-mcp`) later — those become v2.9+ work. Option C is no improvement over the status quo.

## Consequences

- Easier: users get a "REAL" number on the dashboard with actual session counts and tool calls. The product can finally show A/B evidence ("with Tokenso rules + wrap: agents made 40% fewer Read calls").
- Harder: another directory to manage (`.ai-memory/sessions/`). Best-practice docs need to recommend `tokenso wrap` for headless usage.
- Revisit when:
  - IDE/MCP coverage matters → ship `tokenso-mcp` server that listens for tool-call hooks.
  - Sessions directory grows unbounded → add `tokenso sessions --prune` or auto-archive after N days.

## Action Items
- [x] `run_wrap` in `bin/tokenso` (universal + structured + heuristic tiers).
- [x] `run_sessions` to list past wrapped sessions.
- [x] `_aggregate_observed` (inlined) in `generate_html_dashboard` to compute totals.
- [x] "Observed Activity" panel (HTML + CSS + JS) with REAL badge and empty-state recipe.
- [x] `TOKENSO_DATA.observed` block.
- [x] Rules marker bumped `v2` → `v3` with new "Observable Sessions" rule.
- [x] Bump VERSION 2.6.0 → 2.7.0.
- [ ] Future: `tokenso sessions --prune --keep-days 30` to garbage-collect manifests.
- [ ] Future: ship `tokenso-mcp` MCP server for IDE/desktop agents.
