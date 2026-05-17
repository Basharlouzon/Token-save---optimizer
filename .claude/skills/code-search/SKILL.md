---
name: code-search
description: "Use when you need to find code, trace dependencies, or understand codebase structure without reading entire files. Enforces a search hierarchy that minimizes token spend while maximizing information gained."
---

# Code Search — Zero-Waste Code Snippet Utility

Search code intelligently without overflowing the context window.

## Search Hierarchy (Always Follow This Order)

### Level 1: Repo Map (cheapest)
Read `.ai-memory/repo-map.txt` first. This gives you the full file tree with token estimates in ~20 lines.

```bash
tokenso map                    # view the map
cat .ai-memory/repo-map.txt    # read directly
```

### Level 2: Filename Search (cheap)
Find files by name or path pattern without reading content:

```bash
rg -l "pattern" --type-add 'src:*.{ts,tsx,js,py,go,rs,bash,sh}' -t src
rg -l "UserService" -t ts
find . -name "*.service.ts" -not -path "*/node_modules/*"
```

### Level 3: Content Search (moderate)
Search inside files, returning matching lines with context:

```bash
rg -n "pattern" -C 2           # 2 lines of context around each match
rg -n "export function" -t ts  # find all exports
rg -n "TODO|FIXME|HACK"        # find technical debt markers
```

### Level 4: Targeted File Read (expensive, use sparingly)
Only after identifying the exact file and line range:

```bash
sed -n '100,150p' src/file.ts
```

## Pattern Matching Quick Reference

| Goal | Pattern |
|------|---------|
| Function definitions | `rg -n "^(export\s+)?(async\s+)?function\s+\w+"` |
| Class declarations | `rg -n "^class\s+\w+"` |
| Imports/requires | `rg -n "^import.*from|^const.*require"` |
| API endpoints | `rg -n "(app\|router)\.(get\|post\|put\|delete)\("` |
| Type definitions | `rg -n "^export (type\|interface)\s+"` |
| Environment variables | `rg -n "process\.env\.\w+"` |
| Error handling | `rg -n "try\s*\{|catch\s*\(" ` |

## Snippet Extraction

Never read an entire file to see one function:

```bash
rg -n "function myFunc" -A 20 file.ts
sed -n '50,100p' file.ts
rg -n "^export" file.ts
```

## Cross-File Tracing

1. `rg -l "import.*ModuleName"` — find all files importing the module.
2. Read only the import section (first ~30 lines) of each file.
3. `rg -n "export.*ModuleName"` in the source file.
4. Never load both files fully.

## Token Cost Estimation

- **1 line** ≈ 4 tokens
- **100 lines** ≈ 400 tokens
- **500 lines** ≈ 2,000 tokens
- **2,000 lines** ≈ 8,000 tokens (avoid full reads)

Use `wc -l file.ts` before reading. If > 200 lines, use targeted reads only.

## Using `tokenso search`

```bash
tokenso search "pattern"       # fuzzy path match + content snippet scan
tokenso search "auth"          # finds auth-related files and shows snippets
```

Results capped at 15 to prevent context overflow.

## Anti-Patterns to Avoid

- Reading entire files to find one function — use `rg -n` first.
- Running `find` on the whole repo — use the repo map.
- Sequential single-pattern searches — combine with `|`.
- Reading the same file twice — record key details in state.md.
- Searching `node_modules/`, `.git/`, build output — always exclude.
