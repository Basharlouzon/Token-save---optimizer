# Implementation Plan: Memory Graph Token Detection & Reading

[Overview]
Enhance the token memory graph (`_save_token_memory_graph`) to detect, read, and analyze token memory patterns from stats history, wrap sessions, and state milestones — producing richer node data with trend analysis, efficiency metrics, and per-session breakdowns.

The current `token-memory-graph.json` is a static snapshot with raw numbers but no intelligence. This plan adds token memory detection (trend direction, peak/avg/min, session efficiency) and deep reading of wrapped session data to produce actionable insights that AI agents can consume directly from the graph file.

[Types]
The JSON schema of `token-memory-graph.json` evolves from schema 1 to schema 2.

**New/modified node structures:**

```
Node: token_memory (enhanced)
{
  "sessions": number,
  "cumulative_saved": number,
  "history": number[],
  "trend": "improving" | "stable" | "declining",
  "avg_per_session": number,
  "peak_session": number,
  "min_session": number,
  "last_session": number,
  "efficiency_pct": number  // avg/raw_tokens * 100
}

Node: observed_metrics (NEW)
{
  "total_wrap_sessions": number,
  "total_reads": number,
  "total_searches": number,
  "total_bash": number,
  "total_edits": number,
  "total_bytes_read": number,
  "avg_reads_per_session": number,
  "avg_edits_per_session": number
}

Node: milestone_analysis (NEW)
{
  "total_milestones": number,
  "recent_milestones": string[],  // last 5
  "has_low_signal": boolean       // flags test/tmp/foo entries
}
```

**New edges:**
```
{ "from": "observed_metrics", "to": "token_memory", "data": "observed→estimated correlation" }
{ "from": "milestone_analysis", "to": "memory_state", "data": "quality→state health" }
{ "from": "tokenso_core", "to": "observed_metrics", "data": "engine→real metrics" }
```

[Files]
All changes are in a single existing file:

- **`bin/tokenso`** — Modify `_save_token_memory_graph()` function (~line 3339) to:
  1. Compute trend analysis from history array
  2. Read and aggregate wrap session data from `.ai-memory/sessions/*.json`
  3. Analyze milestone quality from state.md
  4. Add new nodes and edges to the JSON output
  5. Bump schema to 2

No new files needed. No files deleted.

[Functions]

**Modified function:** `_save_token_memory_graph()` in `bin/tokenso` (~line 3339)

Current signature: `_save_token_memory_graph() { local raw=$1 map=$2 saved=$3 pct=$4`

Changes:
- After reading HISTORY_ARR, compute trend direction: compare last 3 sessions avg vs first 3 sessions avg → "improving" (>10% growth), "stable", or "declining"
- Compute avg_per_session, peak_session, min_session, last_session from HISTORY_ARR
- Compute efficiency_pct = (avg_saved / raw_tokens) * 100
- Read `.ai-memory/sessions/*.json` to aggregate observed tool call metrics (same pattern as `generate_html_dashboard`)
- Read milestones from state.md and detect low-signal entries (test/tmp/foo patterns)
- Build `observed_metrics` node and `milestone_analysis` node
- Add 3 new edges
- Set `"schema": 2`

[Classes]
No classes involved (bash script).

[Dependencies]
No new dependencies. Uses existing tools: `jq` (optional, with grep fallback), `awk`, `grep`, `stat`.

[Testing]
- Run `bash -n bin/tokenso` to verify syntax
- Run `tokenso run` and verify `token-memory-graph.json` contains new fields
- Verify with `jq . .ai-memory/token-memory-graph.json` that schema=2 and new nodes exist
- Verify graceful handling when no wrap sessions exist (observed_metrics should have zeros)
- Verify graceful handling when no state.md exists (milestone_analysis should have empty arrays)

[Implementation Order]
1. Add trend computation logic (avg, peak, min, trend direction) after HISTORY_ARR loading
2. Add observed_metrics aggregation (reuse wrap session reading pattern from generate_html_dashboard)
3. Add milestone_analysis with low-signal detection
4. Update the cat heredoc to include new nodes and edges with schema 2
5. Verify syntax with `bash -n bin/tokenso`
6. Run `tokenso run` and validate output JSON
7. Push to GitHub