# Repo Mapper — Compressed Repository Map Generation

Generate ultra-compressed repository maps with token estimation so AI agents can understand project structure without expensive `find` or `tree` commands. Use when setting up a new project or when the project structure has changed significantly.

## Overview

The repo mapper creates `.ai-memory/repo-map.txt` — a tiny file (~20 lines) that replaces expensive operations like `ls -R`, `find`, or `tree`. AI agents read this compressed map instead of exploring the entire codebase.

## Invocation

```bash
# Via Tokenso CLI (preferred)
tokenso map                        # view the map with colorized output
tokenso save                       # regenerate map + update stats

# Via script directly
bash .ai-memory/scripts/init-smart-search.sh .

# Via the source script
bash scripts/init-smart-search.sh .
```

## Map Format

The output is a compressed tree structure with token estimates:

```
tokenso/  [~2,400 tokens]
├── bin/
│   └── tokenso                    (2444 lines, bash)
├── scripts/
│   ├── apply-cross-rules.sh       (78 lines, bash)
│   └── init-smart-search.sh       (64 lines, bash)
├── install.sh                     (343 lines, bash)
├── README.md                      (384 lines)
├── SKILL.md                       (63 lines)
└── .ai-memory/
    ├── repo-map.txt
    ├── state.md
    └── optimizer-stats.json
```

## Generation Algorithm

### Primary: `tree`
If `tree` is available on the system:

```bash
tree -I "$EXCLUDES" --dirsfirst -F
```

### Fallback: `find`
If `tree` is not installed:

```bash
find . -not -path "*/$EXCLUDES/*" -not -name "$EXCLUDES" | sort
```

### Exclusion Patterns

The following are always excluded to keep the map small and relevant:

```
.git
node_modules
__pycache__
dist
build
.next
.nuxt
.target
vendor
.bundle
.min
.DS_Store
*.lock
package-lock.json
yarn.lock
pnpm-lock.yaml
*.min.js
*.min.css
*.woff
*.woff2
*.ttf
*.eot
*.png
*.jpg
*.jpeg
*.gif
*.ico
*.svg
*.mp4
*.mp3
*.wav
*.pdf
*.zip
*.tar
*.gz
```

## Token Estimation

The mapper estimates token count using the formula:

```
estimated_tokens = (word_count × 4) / 3
```

This provides a rough estimate so agents can gauge the cost of reading a file before committing context.

## Staleness Detection

The map can become stale when files are added, removed, or renamed. Detect staleness by comparing the map's modification time against recent file changes:

```bash
# Check if any source file is newer than the map
find . -newer .ai-memory/repo-map.txt -not -path "./.git/*" -not -path "./node_modules/*" | head -5
```

If any files are found, suggest a refresh:

```
The repo map appears stale (files modified since last map generation).
Run `tokenso save` to refresh it.
```

## Project-Type Exclusions

The mapper can apply additional exclusions based on project type:

| Project Type | Additional Exclusions |
|-------------|----------------------|
| Flutter/Dart | `.dart_tool`, `android/`, `ios/`, `.pub-cache` |
| Node.js | `.next/`, `.nuxt/`, `coverage/`, `.cache/` |
| Python | `__pycache__/`, `.venv/`, `*.egg-info/`, `.tox/` |
| Rust | `target/` |
| Go | `vendor/` (if using modules) |
| Java/Kotlin | `.gradle/`, `build/`, `.idea/` |

## Integration with Other Commands

| Command | Integration |
|---------|-------------|
| `tokenso map` | Displays the map with colorized output |
| `tokenso save` | Regenerates the map, then updates stats and state.md |
| `tokenso install` | Generates the initial map during project setup |
| `tokenso search` | Uses the map to locate candidate files before content search |

## Map as Search Index

The repo map doubles as a lightweight search index:

- **Path-based search**: `tokenso search "auth"` finds files with "auth" in their path.
- **Structure understanding**: Agents read the map to find relevant directories without `ls`.
- **Size awareness**: Token estimates help agents decide which files to read.

## Best Practices

- **Regenerate after structural changes** — new directories, renamed files, deleted modules.
- **Don't exclude source files** — the map should show all code files, just not binary/generated ones.
- **Keep it under 50 lines** — if the map is too large, it defeats the purpose. Add more exclusions.
- **Commit the scripts, not the map** — `.ai-memory/` is gitignored. The map regenerates per-machine.
