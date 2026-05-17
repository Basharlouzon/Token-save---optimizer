---
name: code-search
description: "Use when finding code, tracing dependencies, or understanding codebase structure without reading entire files. Enforces zero-waste search hierarchy with token cost estimation."
---

# Code Search — Zero-Waste Code Snippet Utility

## The Tokenso Search Command

```bash
tokenso search <query>
```

Two passes internally (`bin/tokenso:689-792`):

1. **Fuzzy Path Search** — scans `.ai-memory/repo-map.txt`. Not capped.
2. **Source Code Snippet Scan** — `rg` (preferred) or `grep` (fallback). Capped at **15 matches**.

Source files filtered through unified exclusions: `.git`, `node_modules`, `build`, `dist`, `.ai-memory`, plus binary/image/archive extensions.

Output:
```
🔍 Zero-Waste Code Search  Query: 'handleSubmit'

  [ 📁 Codebase Blueprint Matches ]
    • src/forms/LoginForm.tsx
    • src/hooks/useForm.ts

  [ 📝 Source Code Matches (Max 15) ]
  📂 src/forms/LoginForm.tsx
     Line 42: const handleSubmit = async (e) => {

  Searched 47 files | Found 3 matches | Showing top 2 | Done in 0s
```

## Search Hierarchy

### Level 1: Repo Map (cheapest)
```bash
tokenso map
cat .ai-memory/repo-map.txt
```

### Level 2: Filename Search
```bash
rg -l "pattern" -t ts
find . -name "*.service.ts" -not -path "*/node_modules/*"
```

### Level 3: Content Search
```bash
rg -n "pattern" -C 2
rg -n "TODO|FIXME|HACK"
```

### Level 4: Targeted Read
```bash
sed -n '100,150p' src/file.ts
```

## Pattern Quick Reference

| Goal | Pattern |
|------|---------|
| Functions | `rg -n "^(export\s+)?(async\s+)?function\s+\w+"` |
| Classes | `rg -n "^class\s+\w+"` |
| Imports | `rg -n "^import.*from\|^const.*require"` |
| API routes | `rg -n "(app\|router)\.(get\|post\|put\|delete)\("` |
| Types | `rg -n "^export (type\|interface)\s+"` |
| Env vars | `rg -n "process\.env\.\w+"` |

## Token Cost Estimation

Formula: `words × 13 / 10`. Rough guide: 100 lines ≈ 400 tokens. Use `wc -l` before reading. If > 200 lines, use targeted reads only.

## Anti-Patterns

- Reading entire files for one function — use `rg -n` first.
- Running `find` on the whole repo — use the repo map.
- Sequential single-pattern searches — combine with `|`.
- Reading same file twice — record in `state.md`.
- Searching `node_modules/`, `.git/` — excluded by default.
