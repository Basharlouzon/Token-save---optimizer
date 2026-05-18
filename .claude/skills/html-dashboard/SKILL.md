---
name: html-dashboard
description: "Use when creating or modifying the glassmorphic HTML dashboard. Covers SVG charts, responsive layout, ROI simulator, and single-file output."
---

# HTML Dashboard Generation

Implementation: `generate_html_dashboard()` at `bin/tokenso:794-1946`.

## Invocation

```bash
tokenso stats --html    # generates tokenso-dashboard.html
```

Single-file HTML — all CSS, JS, SVG inline. Zero external dependencies. Renders fully offline.

## Design System

| Element | Style |
|---------|-------|
| Background | `#0f0f1a` → `#1a1a2e` |
| Cards | `rgba(255,255,255,0.05)` + `backdrop-filter: blur(10px)` |
| Borders | `rgba(255,255,255,0.1)` |
| Accent cyan | `#00d4ff` |
| Accent green | `#00ff88` |
| Accent purple | `#a855f7` |
| Cost baseline | $3.00/1M tokens |

System fonts: `ui-sans-serif, -apple-system, BlinkMacSystemFont, ...` — no web fonts needed.

## Components

1. **Header** — Logo + title + action toolbar (`#btn-copy-md`, `#btn-print`) + "Active Project" badge.
2. **Stats Cards** — 4 KPI cards (sessions, tokens saved, USD saved, compression factor). Each has:
   - Animated count-up (eased; respects `prefers-reduced-motion`).
   - Inline `<svg class="card-sparkline">` showing trend across `history[]`.
3. **SVG Charts** — Radial gauge (`stroke-dasharray`) + big savings-history line chart with hover tooltip.
4. **ROI Simulator** — Interactive: cost/1M, tokens/run, runs/day → monthly/yearly projections.
5. **Milestone Timeline** — From lines beginning with `!` in `.ai-memory/state.md`.
6. **Toast** — Bottom-center `#toast`; toggled by `showToast(msg)` (auto-hides after 1.8s).
7. **Footer** — Dynamic `#ft-version` from `TOKENSO_DATA.version` + repo link.

## Export & Print

- **Copy as Markdown** — `copyAsMarkdown()` builds a report via `buildMarkdownReport()`. Tries `navigator.clipboard.writeText`, falls back to `execCommand('copy')` if the API throws (sandbox/permissions).
- **Print / Save-as-PDF** — `window.print()`. The `@media print` block flips to B&W, hides interactive controls (`.action-buttons`, `.toast`, sliders, model buttons), and uses solid borders for paper.
- **Keyboard** — `C` triggers copy, `P` triggers print. Both ignored when focus is on `INPUT`/`TEXTAREA` or when a modifier key is held.

## Accessibility

ARIA labels on gauge/milestones/charts. Units on ROI sliders. Dashed accent line for colorblind users.

## Data Source

`.ai-memory/optimizer-stats.json` — parsed with `jq` (preferred) or grep/awk fallback.

## Adding Widgets

1. Extract data in `generate_html_dashboard()`.
2. Add HTML/CSS section.
3. Add JS handlers if interactive.
4. Keep single-file.
5. Test: `tokenso stats --html` → open in browser.
