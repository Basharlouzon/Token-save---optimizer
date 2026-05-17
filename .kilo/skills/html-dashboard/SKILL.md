# HTML Dashboard Generation

Generate premium glassmorphic HTML dashboards with SVG charts, interactive widgets, and responsive layouts. Use when creating visual reports from `.ai-memory/optimizer-stats.json` data.

## Overview

The HTML dashboard is a single-file HTML page with no external dependencies. It visualizes Tokenso optimizer stats including token savings, session history, cost reduction, and milestones.

## Invocation

```bash
tokenso stats --html    # generates tokenso-dashboard.html in the current directory
```

## Design System

### Glassmorphic Theme

The dashboard uses a dark glassmorphic design:

| Element | Style |
|---------|-------|
| Background | Dark gradient (`#0f0f1a` → `#1a1a2e`) |
| Cards | Frosted glass (`rgba(255,255,255,0.05)`) with `backdrop-filter: blur(10px)` |
| Borders | Subtle (`rgba(255,255,255,0.1)`) |
| Text | White primary, `rgba(255,255,255,0.7)` secondary |
| Accent | Cyan (`#00d4ff`), Green (`#00ff88`), Purple (`#a855f7`) |

### Color Palette

```
Primary accent:  #00d4ff (cyan)
Success:         #00ff88 (green)
Warning:         #fbbf24 (amber)
Error:           #ef4444 (red)
Info:            #a855f7 (purple)
Neutral:         #64748b (slate)
```

## Dashboard Components

### 1. Header

ASCII art "TOKENSO" banner with animated gradient text and version number.

### 2. Stats Cards

Top-row stat cards showing:
- Total Sessions
- Tokens Saved
- Estimated Cost Saved
- Average Savings/Session

Each card has an icon, value, label, and subtle glow effect.

### 3. SVG Charts

#### Radial Gauge
A circular SVG gauge showing savings percentage (0-100%). Uses `stroke-dasharray` and `stroke-dashoffset` for the arc.

```svg
<circle cx="60" cy="60" r="50" stroke="#1e293b" stroke-width="10" fill="none" />
<circle cx="60" cy="60" r="50" stroke="#00d4ff" stroke-width="10" fill="none"
  stroke-dasharray="314" stroke-dashoffset="94" transform="rotate(-90 60 60)" />
```

#### Bar Chart
Session-by-session token savings as vertical bars with gradient fills.

#### Sparkline
Compact inline trend chart using SVG `<polyline>`.

### 4. ROI Simulator

Interactive widget that lets users input:
- Their token cost per 1M tokens
- Their average session length
- Number of sessions per day

Shows projected monthly/yearly savings with animated counters.

### 5. Milestone Timeline

Vertical timeline of milestones from `.ai-memory/state.md`, with timestamps and descriptions.

### 6. Model Comparison Table

Table showing ROI by AI model (Claude, GPT-4, Gemini, etc.) with cost per 1M tokens and estimated savings.

## Data Source

All data comes from `.ai-memory/optimizer-stats.json`:

```json
{
  "sessions": 12,
  "tokens_saved": 274693,
  "installed": "2026-05-17",
  "cost_per_1m": 3.00,
  "history": [
    { "date": "2026-05-17", "tokens_saved": 45000 }
  ]
}
```

The `generate_html_dashboard()` function in `bin/tokenso` (lines ~794-1946) reads this JSON and generates the full HTML.

## Layout Structure

```html
<html>
<head>
  <style>
    /* All CSS inline — no external deps */
    /* Responsive grid: 4-col on desktop, 2-col on tablet, 1-col on mobile */
  </style>
</head>
<body>
  <div class="dashboard">
    <header>ASCII banner</header>
    <div class="stats-grid">4 stat cards</div>
    <div class="charts-grid">
      <div class="radial-gauge">SVG gauge</div>
      <div class="bar-chart">SVG bars</div>
    </div>
    <div class="roi-simulator">Interactive widget</div>
    <div class="milestone-timeline">Timeline</div>
    <div class="model-table">Comparison table</div>
    <footer>Credits + version</footer>
  </div>
  <script>
    /* All JS inline */
    /* ROI calculator logic */
    /* Animated counters */
    /* No external libraries */
  </script>
</body>
</html>
```

## Adding New Widgets

To add a new component to the dashboard:

1. Add the data extraction in `generate_html_dashboard()` (read from stats JSON).
2. Add the HTML/CSS for the new section.
3. If interactive, add JS event handlers in the `<script>` block.
4. Keep everything in the single-file output — no external dependencies.
5. Test with `tokenso stats --html` and open in a browser.

## Customization

Users can customize the dashboard by:
- Modifying `cost_per_1m` in `.ai-memory/optimizer-stats.json` for their pricing tier.
- Adding milestones via `tokenso save "milestone description"`.
- Regenerating at any time with `tokenso stats --html`.
