---
name: repo-mapper
description: "Use when setting up a new project or when the project structure has changed. Generates ultra-compressed repository maps with token estimation so AI agents can understand structure without expensive exploration."
---

# Repo Mapper — Compressed Repository Map Generation

Generate ultra-compressed repository maps with token estimation.

## Invocation

```bash
tokenso map                        # view colorized map
tokenso save                       # regenerate map + update stats
bash .ai-memory/scripts/init-smart-search.sh .
bash scripts/init-smart-search.sh .
```

## Map Format

```
tokenso/  [~2,400 tokens]
├── bin/
│   └── tokenso                    (2444 lines, bash)
├── scripts/
│   ├── apply-cross-rules.sh       (78 lines, bash)
│   └── init-smart-search.sh       (64 lines, bash)
├── install.sh                     (343 lines, bash)
├── README.md                      (384 lines)
└── .ai-memory/
    ├── repo-map.txt
    ├── state.md
    └── optimizer-stats.json
```

## Generation Algorithm

**Primary**: `tree -I "$EXCLUDES" --dirsfirst -F`
**Fallback**: `find . -not -path "*/$EXCLUDES/*" | sort`

## Exclusion Patterns

Always excluded: `.git`, `node_modules`, `__pycache__`, `dist`, `build`, `.next`, `vendor`, `*.lock`, binary files, images, fonts, archives.

## Token Estimation

```
estimated_tokens = (word_count × 4) / 3
```

## Staleness Detection

```bash
find . -newer .ai-memory/repo-map.txt -not -path "./.git/*" -not -path "./node_modules/*" | head -5
```

If files found → suggest `tokenso save` to refresh.

## Project-Type Exclusions

| Type | Additional Exclusions |
|------|----------------------|
| Flutter/Dart | `.dart_tool`, `android/`, `ios/` |
| Node.js | `.next/`, `.nuxt/`, `coverage/` |
| Python | `__pycache__/`, `.venv/`, `*.egg-info/` |
| Rust | `target/` |
| Java/Kotlin | `.gradle/`, `build/`, `.idea/` |

## Integration

| Command | Usage |
|---------|-------|
| `tokenso map` | Display colorized map |
| `tokenso save` | Regenerate + update stats |
| `tokenso install` | Initial generation |
| `tokenso search` | Uses map to locate files |

## Best Practices

- Regenerate after structural changes.
- Keep map under 50 lines — add exclusions if needed.
- `.ai-memory/` is gitignored — map regenerates per-machine.
