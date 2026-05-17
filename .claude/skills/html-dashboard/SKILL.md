---
name: html-dashboard
description: "Use when creating or modifying the glassmorphic HTML dashboard for Tokenso stats. Covers SVG chart generation, responsive layout, interactive ROI simulator, and single-file HTML output."
---

# HTML Dashboard Generation

Generate premium glassmorphic HTML dashboards with SVG charts and interactive widgets from `.ai-memory/optimizer-stats.json` data.

## Invocation

```bash
tokenso stats --html    # generates tokenso-dashboard.html
```

## Design System

### Glassmorphic Theme

| Element | Style |
|---------|-------|
| Background | Dark gradient (`#0f0f1a` → `#1a1a2e`) |
| Cards | Frosted glass (`rgba(255,255,255,0.05)`) with `backdrop-filter: blur(10px)` |
| Borders | `rgba(255,255,255,0.1)` |
| Text | White primary, `rgba(255,255,255,0.7)` secondary |
| Accent | Cyan `#00d4ff`, Green `#00ff88`, Purple `#a855f7` |

### Color Palette

```
Primary:   #00d4ff (cyan)
Success:   #00ff88 (green)
Warning:   #fbbf24 (amber)
Error:     #ef4444 (red)
Info:      #a855f7 (purple)
Neutral:   #64748b (slate)
```

## Dashboard Components

### 1. Header
ASCII art "TOKENSO" banner with animated gradient text.

### 2. Stats Cards (top row)
Total Sessions, Tokens Saved, Estimated Cost Saved, Avg Savings/Session.

### 3. SVG Charts

#### Radial Gauge
Circular SVG gauge using `stroke-dasharray` / `stroke-dashoffset` for savings percentage.

#### Bar Chart
Per-session token savings as vertical bars with gradient fills.

#### Sparkline
Compact inline trend using SVG `<polyline>`.

### 4. ROI Simulator
Interactive: inputs for token cost, session length, sessions/day. Shows projected savings.

### 5. Milestone Timeline
Vertical timeline from `.ai-memory/state.md`.

### 6. Model Comparison Table
ROI by AI model with cost per 1M tokens.

## Data Source

`.ai-memory/optimizer-stats.json`:

```json
{
  "sessions": 12,
  "tokens_saved": 274693,
  "installed": "2026-05-17",
  "cost_per_1m": 3.00,
  "history": [{ "date": "2026-05-17", "tokens_saved": 45000 }]
}
```

## Layout Structure

Single-file HTML — all CSS and JS inline, no external dependencies. Responsive grid: 4-col desktop, 2-col tablet, 1-col mobile.

Implementation is in `generate_html_dashboard()` in `bin/tokenso` (~lines 794-1946).

## Adding New Widgets

1. Extract data from stats JSON in `generate_html_dashboard()`.
2. Add HTML/CSS section.
3. Add JS handlers if interactive.
4. Keep everything single-file.
5. Test: `tokenso stats --html` → open in browser.

## Customization

- Modify `cost_per_1m` in `.ai-memory/optimizer-stats.json`.
- Add milestones via `tokenso save "description"`.
- Regenerate anytime with `tokenso stats --html`.
