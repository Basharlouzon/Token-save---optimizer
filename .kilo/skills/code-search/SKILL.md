# Code Search — Zero-Waste Code Snippet Utility

Search code intelligently without overflowing the context window. Use when you need to find code, trace dependencies, or understand codebase structure without reading entire files.

## Philosophy

Every file read costs tokens. Every unnecessary line wastes context. This skill enforces a search hierarchy that minimizes token spend while maximizing information gained.

## Search Hierarchy (Always Follow This Order)

### Level 1: Repo Map (cheapest)
Read `.ai-memory/repo-map.txt` first. This gives you the full file tree with token estimates in a compressed format (~20 lines for most projects). Use it to identify candidate files before any search.

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
Search inside files, but only return matching lines with context:

```bash
rg -n "pattern" -C 2           # 2 lines of context around each match
rg -n "export function" -t ts  # find all exports
rg -n "TODO|FIXME|HACK"        # find technical debt markers
```

### Level 4: Targeted File Read (expensive, use sparingly)
Only after identifying the exact file and line range:

```bash
# Read specific line range only
sed -n '100,150p' src/file.ts
# Or use your tool's offset/limit parameters
```

## Pattern Matching Quick Reference

Common search patterns for code exploration:

| Goal | Pattern |
|------|---------|
| Function definitions | `rg -n "^(export\s+)?(async\s+)?function\s+\w+"` |
| Class declarations | `rg -n "^class\s+\w+"` |
| Imports/requires | `rg -n "^import.*from|^const.*require"` |
| Config keys | `rg -n "^\s+\w+:" config.yml` |
| API endpoints | `rg -n "(app\|router)\.(get\|post\|put\|delete)\("` |
| Type definitions | `rg -n "^export (type\|interface)\s+"` |
| Environment variables | `rg -n "process\.env\.\w+"` |
| Event handlers | `rg -n "on\w+\s*[=(]"` |
| Error handling | `rg -n "try\s*\{|catch\s*\(" ` |

## Snippet Extraction

Never read an entire file to see one function. Extract only what you need:

```bash
# Extract a specific function (from definition to closing brace)
rg -n "function myFunc" -A 20 file.ts

# Extract lines 50-100 only
sed -n '50,100p' file.ts

# Extract all exports from a module
rg -n "^export" file.ts
```

## Cross-File Tracing

When tracing a dependency chain across files:

1. Start with `rg -l "import.*ModuleName"` to find all files importing the module.
2. Read only the import section of each file (first ~30 lines usually).
3. Trace the export side with `rg -n "export.*ModuleName"` in the source file.
4. Never load both files fully — read only the relevant sections.

## Token Cost Estimation

Before reading a file, estimate the cost:

- **1 line** ≈ 4 tokens
- **100 lines** ≈ 400 tokens
- **500 lines** ≈ 2,000 tokens
- **2,000 lines** ≈ 8,000 tokens (avoid full reads)

Use `wc -l file.ts` to check line count before reading. If > 200 lines, use targeted reads only.

## Using `tokenso search`

The built-in search command handles the hierarchy automatically:

```bash
tokenso search "pattern"       # fuzzy path match + content snippet scan
tokenso search "auth"          # finds auth-related files and shows snippets
```

It caps results at 15 to prevent context overflow and shows compact snippets with line numbers.

## Integration with Memory Protocol

After a significant search session:

1. Record key findings in `.ai-memory/state.md`.
2. Note file locations and architectural insights discovered.
3. Run `tokenso save --silent` to update stats without verbose output.

## Anti-Patterns to Avoid

- **Reading entire files to find one function** — use `rg -n` with line numbers first.
- **Running `find` on the whole repo** — use the repo map instead.
- **Sequential single-pattern searches** — combine patterns with `|` in one pass.
- **Reading the same file twice** — if you've already read it, recall from context or note the key details in state.md.
- **Searching `node_modules/`, `.git/`, build output** — always exclude these: `rg --glob '!.git' --glob '!node_modules' --glob '!dist'`.
