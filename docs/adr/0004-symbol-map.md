# ADR-0004: Symbol map alongside the repo map

**Status:** Accepted
**Date:** 2026-05-18
**Version target:** v2.6.0

## Context

`tokenso map` produces `.ai-memory/repo-map.txt` — a `tree`-style listing of file paths. It tells an agent *which files exist* but nothing about *what's inside them*. To answer "where is `handleAuth` defined?" an agent still has to read entire files. That's where the actual token waste happens.

The repo-map approach was the right starting point, but it's a directory of book *titles* — useful, but not the index. The next leverage point is a *symbol index*: one line per function/class/type, with `path:line` jump targets.

A naive symbol index would balloon — large monorepos have tens of thousands of symbols. The trick is to cap it to a token budget and to lean on Universal Ctags when available so we don't write yet another parser per language.

## Decision

Ship `.ai-memory/symbol-map.txt` produced by a new `scripts/build-symbol-map.sh`. Format: `path:line<TAB>kind<TAB>name`, one symbol per line, capped at 800 symbols by default (`TOKENSO_SYMBOL_CAP`). Two extraction backends:

- **Universal Ctags** if installed — handles 40+ languages.
- **Portable awk regex fallback** for JS/TS, Python, Bash, Go, Rust, Ruby (covers the long tail of real-world agent work).

New `tokenso symbols [name]` command surfaces the index. `tokenso map` and `tokenso smart` build/refresh the symbol map alongside the repo map. Dashboard adds an "Indexed Symbols" stat. Injected agent rules are bumped to `v2` and tell agents: **check symbol-map.txt BEFORE opening files.**

## Options Considered

### Option A — Ctags + regex fallback, single file output (chosen)
| Dimension | Score | Note |
|-----------|-------|------|
| Token cost | Low | ~10 words/symbol × 800 cap ≈ 1200 tokens vs 20K+ for full file reads |
| Bash portability | High | Uses POSIX awk (match/RSTART/RLENGTH/substr); explicitly avoids gawk `match(...,array)` |
| Dependencies | Optional | ctags preferred, regex fallback works with just awk |
| Cross-tool reach | High | Agent rules updated to v2 marker; re-injects on next run |
| Install surface | Small | One new script + opportunistic curl on first `tokenso map` if missing |
| Migration cost | Zero | Additive; old `repo-map.txt` workflows unchanged |
| Reversibility | High | Delete the script + revert one rules-template change |

**Pros:** Hits the actual token-saving thesis. Works offline. Composes with existing `tokenso search`.
**Cons:** Awk regex isn't tree-sitter — will mismatch edge cases (multi-line function signatures, e.g.). Acceptable for v1; ctags handles those when present.

### Option B — Tree-sitter via WASM bindings
Use tree-sitter compiled to WASM, run via Node or QuickJS.

**Pros:** Accurate parsing across all languages.
**Cons:** Adds Node/WASM dependency — breaks "pure bash" branding. Build & distribution complexity.

### Option C — Defer to user; document `ctags -R` in CLAUDE.md
**Pros:** No code.
**Cons:** Most users never run it. The product needs to do this *for* them.

## Trade-off

Option A wins because the marginal value of perfect parsing (Option B) is small compared to the cost of the dependency. Regex catches 90%+ of top-level symbols, which is exactly the population agents need to navigate quickly. Universal Ctags users automatically get accuracy upgrades.

## Consequences

- Easier: agents can answer "where is X defined?" with one grep instead of opening files.
- Harder: another `.ai-memory/` file to keep fresh — handled by `tokenso smart` and `_ensure_symbol_map`.
- Revisit when: real users on monorepos hit the 800-symbol cap, or when we want symbol *references* (callers) rather than just definitions.

## Action Items
- [x] `scripts/build-symbol-map.sh` (ctags + regex fallback).
- [x] `tokenso symbols [filter]` command.
- [x] `_ensure_symbol_map` helper; called from `run_map` and `run_smart`.
- [x] Bump rules marker `v1` → `v2`; add "Symbol Lookup First" rule.
- [x] Dashboard surface: `symbolCount` in TOKENSO_DATA + "Indexed Symbols" details row.
- [x] Smart report adds `symbols: N` line.
- [x] Bump VERSION 2.5.1 → 2.6.0.
- [ ] Future: track symbol *references* (callers) for impact-analysis questions.
- [ ] Future: cache by file mtime so rebuilds are incremental.
