# ADR-0007: Command polish — search-aware-of-symbols, sessions subcommands, observed-status

**Status:** Accepted
**Date:** 2026-05-18
**Version target:** v2.9.0

## Context

After v2.6 (symbol map) + v2.7 (`tokenso wrap`) + v2.8 (smart linter), four commands had visible gaps:

1. **`tokenso search`** never learned to use the symbol map — running `tokenso search drawGauge` would do path + content grep but ignore the much-denser symbol index that already pinpoints `bin/tokenso:1860 fn drawGauge`.
2. **`tokenso sessions`** could only list. A user who racked up dozens of wrap manifests had no way to inspect one (`show`), see the most recent (`last`), or clean up old ones (`prune`).
3. **`tokenso status`** showed estimated savings + map/state/agent counts but ignored the new observed-activity surface entirely — making `tokenso wrap` invisible from the daily one-liner.
4. **`tokenso doctor`** didn't check the `tk` alias (v2.8.1+) or the symbol map (v2.6+) — so its "16 checks pass" report wasn't telling the whole story.

All four are command polish, not architecture changes. They wire existing data sources into the right places.

## Decision

Land all four upgrades in a single minor release (v2.9.0) since they touch four different code paths with no risky shared state:

1. **Symbol-aware search.** Add a `[ 🔣 Symbol Map Matches ]` section to `run_search` output, between path and content. Caps at 15 with overflow hint pointing to `tokenso symbols`. Read-only access to `.ai-memory/symbol-map.txt` — never modifies.
2. **`tokenso sessions <subcommand>`.** Default still lists; new subcommands `show <id|prefix>`, `last`, `prune --keep N|--keep-days N [--dry-run]`. ID prefix matching makes `show 20260518T13` work without typing the full timestamp.
3. **Observed metrics in `tokenso status`.** Adds `N symbols`, watcher indicator (`watch:on`), and a second line `↳ Observed: X wrap session(s), last Nm ago` when sessions exist.
4. **`tokenso doctor`** checks: `tk` symlink presence/integrity, `symbol-map.txt` presence + non-emptiness, wrapped-session count (warning when > 100).

## Options Considered

### Option A — Single v2.9.0 with all four (chosen)
| Dimension | Score | Note |
|-----------|-------|------|
| Token cost | Same / lower | Symbol matches surface high-density results before content grep |
| Bash portability | High | All POSIX awk/grep/find |
| Dependencies | Optional | jq preferred for sessions show/prune, grep fallback already exists |
| Cross-tool reach | None new | Internal command behavior |
| Install surface | None | No new files, no marker bump |
| Migration cost | Zero | All additive — same commands, more output |
| Reversibility | High | Each change is one isolated function edit |

**Pros:** Cohesive narrative ("command polish release"). All four ride one update.
**Cons:** Bigger changelog entry. Mitigated by clear sub-sections.

### Option B — Four separate patch releases (v2.8.3, v2.8.4, etc.)
**Pros:** Easier to revert individual changes.
**Cons:** Each forces users to `tokenso update` again. Patch versions historically signal fixes, not enhancements — this would muddy semver.

### Option C — Defer doctor + status (smaller scope)
**Pros:** Even faster ship.
**Cons:** Wrap users still can't see their data from `tokenso status`. Defeats half the point.

## Trade-off

Option A wins because none of the four changes interact with shared state — search reads symbol-map, sessions reads its own dir, status reads stats + sessions read-only, doctor only emits. Atomicity is essentially free. Splitting them would just multiply release overhead.

## Consequences

- Easier: `tokenso search foo` now answers "where is foo?" in one shot. `tokenso sessions prune --keep 50` keeps the manifest dir bounded. `tokenso status` is the at-a-glance health check.
- Harder: more output from `tokenso search` — mitigated by clear section headers and caps. Future regressions need to remember to keep the symbol-map section before the content section (order matters).
- Revisit when:
  - Symbol-map matches grow noisy → add a `--no-symbols` flag.
  - Prune defaults are unclear → add a "tokenso sessions prune" warning when > N.
  - Observed status gets crowded → consider a separate `tokenso status --full`.

## Action Items
- [x] `run_search` symbol-map section.
- [x] `run_sessions` dispatch + `show` / `last` / `prune` subcommands with `--dry-run`.
- [x] `run_status` symbol count, watcher indicator, observed line.
- [x] `run_doctor` checks `tk` symlink + symbol-map + sessions count.
- [x] Bump VERSION 2.8.2 → 2.9.0.
- [ ] Future: `tokenso search --kind fn|cls` to filter by symbol kind.
- [ ] Future: `tokenso sessions search <pattern>` to grep across manifests.
