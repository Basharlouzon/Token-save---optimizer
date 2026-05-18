# ADR-0002: Dashboard Export, Print, and Polish

**Status:** Accepted
**Date:** 2026-05-18
**Version target:** v2.5.0

## Context

The `tokenso stats --html` dashboard had three rough edges:

1. The footer hardcoded `v2.2.0` and was missed in every release since — visible regression of trust.
2. No way for users to share their savings without taking screenshots.
3. Stat cards were static — the rich `history[]` array sitting in `TOKENSO_DATA` only fed the big line chart, not the cards themselves.

## Decision

We will keep the dashboard a single self-contained HTML file (no build step, no deps) and add:

- A dynamic footer version from `TOKENSO_DATA.version`.
- Inline mini-sparklines in each stat card, rendered as native SVG.
- A "Copy as Markdown" button with `navigator.clipboard` + `execCommand` fallback.
- A "Print" button + `@media print` stylesheet that produces a clean B&W single-page layout.
- Animated count-up numbers respecting `prefers-reduced-motion`.
- `C`/`P` keyboard shortcuts.

## Options Considered

### Option A — Inline JS + SVG, single-file (chosen)
| Dimension | Score | Note |
|-----------|-------|------|
| Token cost | Low | One HTML file, no external network |
| Bash portability | High | Same here-doc pattern as today |
| Dependencies | None | Native Clipboard API + `execCommand` fallback |
| Cross-tool reach | N/A | Dashboard is end-user surface |
| Install surface | None | No installer changes |
| Migration cost | Zero | Pure additive |
| Reversibility | High | Each block is independent; can revert per-feature |

**Pros:** Stays offline-first, no toolchain, matches the project thesis ("just bash").
**Cons:** All logic lives in one bash heredoc — getting long.

### Option B — Switch to a static-site bundler (Vite, Astro)
**Pros:** Easier component reuse, CSS modules, TypeScript.
**Cons:** Adds Node toolchain, breaks "pure bash" branding, blows up install path, requires CI for HTML generation.

### Option C — Defer to native browser screenshot
Drop the buttons; tell users to print/screenshot themselves.
**Pros:** Zero code.
**Cons:** No portable copy/share path; print without `@media print` looks awful (dark glassmorphism on white paper).

## Trade-off

Option A keeps Tokenso's defining constraint (single-file bash) and pays only ~150 lines of additional HTML/CSS/JS. Option B is the right call only if we eventually have *5+* dashboards; for one, the toolchain cost is wrong. Option C ignores the actual user pain (shareability) the feature exists to solve.

## Consequences

- Easier: users can paste their savings into Slack/docs without screenshots; PDF export works one-click.
- Harder: the dashboard heredoc is now ~1180 lines — next addition should consider splitting CSS/JS into separate `cat` blocks or a small `bin/tokenso-dashboard-template` companion.
- Revisit when: dashboard exceeds 1500 lines or we want SSR/per-route components.

## Action Items
- [x] Implementation in `bin/tokenso:824–1946`.
- [x] `tokenso stats --html` regenerates with new widgets.
- [x] Update `.claude/skills/html-dashboard/SKILL.md`.
- [x] Bump VERSION to 2.5.0 + README "What's new".
- [ ] Future: extract CSS/JS sections if `bin/tokenso` ever splits into multiple files.
