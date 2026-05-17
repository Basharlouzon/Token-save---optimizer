# Code Search — Zero-Waste Code Snippet Utility

Search code without overflowing the context window. Use when finding code, tracing dependencies, or understanding codebase structure.

## Philosophy

Every file read costs tokens (formula: `words × 13 / 10`). This skill enforces a search hierarchy that minimizes token spend.

## The Tokenso Search Command

```bash
tokenso search <query>
```

This performs two passes internally (`bin/tokenso:689-792`):

1. **Fuzzy Path Search** — scans `.ai-memory/repo-map.txt` for file paths matching the query. Not capped.
2. **Source Code Snippet Scan** — searches actual source files using `rg` (preferred) or `grep` (fallback). Results capped at **15 matches** to prevent context overflow.

Output format:
```
🔍 Zero-Waste Code Search  Query: 'handleSubmit'

  [ 📁 Codebase Blueprint Matches ]
  ─────────────────────────────────────────
    • src/forms/LoginForm.tsx
    • src/hooks/useForm.ts

  [ 📝 Source Code Matches (Max 15) ]
  📂 src/forms/LoginForm.tsx
     Line 42: const handleSubmit = async (e) => {

  Searched 47 files | Found 3 matches | Showing top 2 | Done in 0s
```

Source files are filtered through the unified exclusion list (from `bin/tokenso:92-93`):
- Excluded dirs: `.git`, `node_modules`, `build`, `dist`, `.dart_tool`, `Pods`, `.gradle`, `.venv`, `__pycache__`, `.idea`, `.vscode`, `.expo`, `.next`, `.nuxt`, `out`, `coverage`, `target`, `.cargo`, `.ai-memory`
- Excluded files: `.png`, `.jpg`, `.gif`, `.ico`, `.pdf`, `.zip`, `.gz`, `.mp4`, `.mp3`, `.woff`, `.ttf`, `.lock`, `.db`, `.exe`, `.dll`, `.so`, `.dylib`, `.class`, `.jar`, `.apk`, `.bundle`

## Manual Search Hierarchy

### Level 1: Repo Map (cheapest)
```bash
tokenso map                    # view colorized map
cat .ai-memory/repo-map.txt    # read raw (~20 lines)
```

### Level 2: Filename Search (cheap)
```bash
rg -l "pattern" --type-add 'src:*.{ts,tsx,js,py,go,rs,bash,sh}' -t src
find . -name "*.service.ts" -not -path "*/node_modules/*" -not -path "*/.git/*"
```

### Level 3: Content Search (moderate)
```bash
rg -n "pattern" -C 2           # 2 lines context around match
rg -n "export function" -t ts
rg -n "TODO|FIXME|HACK"
```

### Level 4: Targeted File Read (expensive)
```bash
sed -n '100,150p' src/file.ts  # only lines 100-150
```

## Pattern Quick Reference

| Goal | Pattern |
|------|---------|
| Function definitions | `rg -n "^(export\s+)?(async\s+)?function\s+\w+"` |
| Class declarations | `rg -n "^class\s+\w+"` |
| Imports/requires | `rg -n "^import.*from\|^const.*require"` |
| API endpoints | `rg -n "(app\|router)\.(get\|post\|put\|delete)\("` |
| Type definitions | `rg -n "^export (type\|interface)\s+"` |
| Environment variables | `rg -n "process\.env\.\w+"` |
| Error handling | `rg -n "try\s*\{|catch\s*\("` |
| Event handlers | `rg -n "on\w+\s*[=(]"` |

## Snippet Extraction

Never read an entire file for one function:

```bash
rg -n "function myFunc" -A 20 file.ts    # function + 20 lines
sed -n '50,100p' file.ts                  # exact range
rg -n "^export" file.ts                   # all exports
```

## Cross-File Tracing

1. `rg -l "import.*ModuleName"` — find all consumers.
2. Read only the import section (first ~30 lines) of each.
3. `rg -n "export.*ModuleName"` — find the source.
4. Never load both files fully.

## Token Cost Estimation

| Lines | Approx Tokens |
|-------|--------------|
| 1 | 4 |
| 100 | 400 |
| 500 | 2,000 |
| 2,000 | 8,000 |

Check with `wc -l file` before reading. If > 200 lines, use targeted reads only.

## Anti-Patterns

- Reading entire files to find one function — use `rg -n` first.
- Running `find` on the whole repo — use the repo map instead.
- Sequential single-pattern searches — combine with `|`.
- Reading the same file twice — record key details in `state.md`.
- Searching `node_modules/`, `.git/`, build output — excluded by default.
