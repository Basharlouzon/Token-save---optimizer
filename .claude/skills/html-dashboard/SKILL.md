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

1. **Header** — ASCII art banner + animated gradient text.
2. **Stats Cards** — Sessions, tokens saved, cost saved, avg/session. 4-col grid.
3. **SVG Charts** — Radial gauge (`stroke-dasharray`), bar chart (per-session), sparkline (`<polyline>`).
4. **ROI Simulator** — Interactive: cost/1M, tokens/run, runs/day → monthly/yearly projections.
5. **Milestone Timeline** — From `.ai-memory/state.md`.
6. **Model Comparison Table** — Claude Sonnet ($3), Opus ($15), GPT-4o ($2.50), Gemini ($1.25).
7. **Footer** — Version + repo link.

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
