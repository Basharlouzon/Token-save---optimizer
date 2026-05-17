---
name: repo-mapper
description: "Use when setting up a project or when structure changes. Generates ultra-compressed repo maps with token estimation (words × 13/10)."
---

# Repo Mapper — Compressed Repository Map Generation

Implementation: `scripts/init-smart-search.sh` (64 lines). Invoked by `tokenso save`, `tokenso install`, `tokenso map`.

## Invocation

```bash
tokenso map                              # view colorized map
tokenso save                             # regenerate + update stats
tokenso save --silent                    # silent regeneration
tokenso install                          # initial generation
bash .ai-memory/scripts/init-smart-search.sh .  # direct
```

## Output

Stored at `.ai-memory/repo-map.txt` (~20 lines):

```
tokenso/  [~2,400 tokens]
├── bin/
│   └── tokenso                    (2444 lines, bash)
├── scripts/
│   ├── apply-cross-rules.sh       (78 lines, bash)
│   └── init-smart-search.sh       (64 lines, bash)
├── install.sh                     (343 lines, bash)
└── .ai-memory/
    ├── repo-map.txt
    ├── state.md
    └── optimizer-stats.json
```

## Generation

- **Primary**: `tree -I "$EXCLUDES" --dirsfirst -F`
- **Fallback**: `find . -not -path "*/$EXCLUDES/*" | sort`

## Exclusions (`bin/tokenso:92-93`)

Excluded dirs: `.git`, `node_modules`, `build`, `dist`, `.ai-memory`, `.dart_tool`, `Pods`, `.gradle`, `.venv`, `__pycache__`, `.idea`, `.vscode`, `.expo`, `.next`, `.nuxt`, `coverage`, `target`, `.cargo`

Excluded files: `.png`, `.jpg`, `.gif`, `.ico`, `.pdf`, `.zip`, `.gz`, `.mp4`, `.mp3`, `.woff`, `.ttf`, `.lock`, `.db`, `.exe`, `.dll`, `.so`, `.dylib`, `.class`, `.jar`, `.apk`, `.bundle`

## Token Estimation

From `run_save()` (`bin/tokenso:656-658`):

```bash
raw_tokens=$(( raw_words * 13 / 10 ))
map_tokens=$(( map_words * 13 / 10 ))
saved_tokens=$(( raw_tokens - map_tokens ))
```

## Lifecycle

1. **Created**: `tokenso install` → `init-smart-search.sh .`
2. **Refreshed**: `tokenso save` overwrites each time.
3. **Viewed**: `tokenso map` with syntax highlighting.
4. **Cleaned**: `tokenso clean` deletes `.ai-memory/` contents.
5. **Auto-recovered**: If script missing, copied from `scripts/` or downloaded from GitHub.

## Staleness Check

```bash
find . -newer .ai-memory/repo-map.txt -not -path "./.git/*" -not -path "./node_modules/*" | head -5
```

## Integration

| Command | Usage |
|---------|-------|
| `tokenso map` | Display colorized map |
| `tokenso save` | Regenerate + stats |
| `tokenso install` | Initial creation |
| `tokenso search` | Fuzzy path matching on map |
| `tokenso clean` | Delete map |
