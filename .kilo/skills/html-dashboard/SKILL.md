# HTML Dashboard Generation

Generate premium glassmorphic HTML dashboards with SVG charts, interactive widgets, and responsive layouts. Implementation lives in `generate_html_dashboard()` at `bin/tokenso:794-1946`.

## Invocation

```bash
tokenso stats --html    # generates tokenso-dashboard.html in current directory
```

Output is a **single-file HTML page** with zero external dependencies. All CSS, JS, and SVG are inline.

## Data Source

Reads from `.ai-memory/optimizer-stats.json`:

```json
{
  "schema": 1,
  "version": "2.2.0",
  "installed": "2026-05-17",
  "sessions": 12,
  "cumulative_saved": 274693,
  "last_run": "2026-05-17",
  "history": [{"date": "2026-05-17", "tokens_saved": 45000}]
}
```

JSON parsing prefers `jq` with grep/awk fallback for the 4 flat fields.

## Design System

### Glassmorphic Theme

| Element | Style |
|---------|-------|
| Background | Dark gradient `#0f0f1a` → `#1a1a2e` |
| Cards | `rgba(255,255,255,0.05)` with `backdrop-filter: blur(10px)` |
| Borders | `rgba(255,255,255,0.1)` |
| Text primary | `#ffffff` |
| Text secondary | `rgba(255,255,255,0.7)` |
| Accent cyan | `#00d4ff` |
| Accent green | `#00ff88` |
| Accent purple | `#a855f7` |
| Cost baseline | $3.00/1M tokens (Claude Sonnet) |

### System Font Stack

```css
font-family: ui-sans-serif, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
```

No web fonts — renders fully offline.

## Dashboard Components

### 1. Header
ASCII art "TOKENSO" banner with animated gradient text. Version number from stats JSON.

### 2. Stats Cards (top row, 4-column grid)
- Total Sessions
- Tokens Saved (formatted with commas)
- Estimated Cost Saved (USD, calculated as `tokens × $3.00 / 1,000,000`)
- Average Savings per Session

Each card: icon, large formatted number, label, subtle glow on hover.

### 3. SVG Charts

#### Radial Gauge
Circular progress gauge for savings percentage. Uses `stroke-dasharray` / `stroke-dashoffset`:

```svg
<circle cx="60" cy="60" r="50" stroke="#1e293b" stroke-width="10" fill="none" />
<circle cx="60" cy="60" r="50" stroke="#00d4ff" stroke-width="10" fill="none"
  stroke-dasharray="314" stroke-dashoffset="94" transform="rotate(-90 60 60)" />
```

#### Bar Chart
Per-session token savings from `history[]` array. Vertical bars with gradient fills.

#### Sparkline
Compact inline trend using SVG `<polyline>`. Rendered in the terminal dashboard too via `draw_sparkline()` (`bin/tokenso:226-260`).

### 4. ROI Simulator
Interactive widget with inputs:
- Token cost per 1M tokens (default $3.00)
- Average session tokens saved
- Sessions per day

Calculates projected monthly/yearly savings with animated counters.

### 5. Milestone Timeline
Vertical timeline reading milestones from `.ai-memory/state.md` completed tasks.

### 6. Model Comparison Table
ROI by AI model:

| Model | Cost/1M tokens | Est. savings |
|-------|---------------|-------------|
| Claude Sonnet | $3.00 | baseline |
| Claude Opus | $15.00 | 5x |
| GPT-4o | $2.50 | 0.83x |
| Gemini 1.5 Pro | $1.25 | 0.42x |

### 7. Footer
Version, repository link, "Star the repo" CTA.

## Layout

```html
<html>
<head><style>/* All CSS inline */</style></head>
<body>
  <div class="dashboard">
    <header>ASCII banner</header>
    <div class="stats-grid">4 cards</div>
    <div class="charts-grid">
      <div class="gauge">SVG radial</div>
      <div class="bar-chart">SVG bars</div>
    </div>
    <div class="roi-simulator">Interactive</div>
    <div class="timeline">Milestones</div>
    <div class="model-table">Comparison</div>
    <footer>Credits</footer>
  </div>
  <script>/* All JS inline */</script>
</body>
</html>
```

Responsive grid: 4-col desktop, 2-col tablet, 1-col mobile. Chart resize is debounced. Chart points support keyboard focus and touch alongside hover.

## Accessibility

- ARIA labels on gauge, milestones, chart points.
- Units on ROI sliders ("15 runs/day", "5,000 tokens/run").
- Dashed accent line on savings chart for colorblind users.

## Adding New Widgets

1. Extract data from stats JSON in `generate_html_dashboard()`.
2. Add HTML/CSS section to the generated output.
3. Add JS handlers if interactive.
4. Keep single-file — no external dependencies.
5. Test: `tokenso stats --html` → open in browser.

## Customization

Users customize by:
- Modifying `cumulative_saved` and `sessions` via normal `tokenso save` usage.
- Adding milestones via `tokenso save "description"`.
- The `history[]` array tracks last 10 runs for sparkline/bar chart.
- Regenerate anytime with `tokenso stats --html`.
