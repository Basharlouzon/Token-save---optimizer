# Repo Mapper — Compressed Repository Map Generation

Generate ultra-compressed repository maps so AI agents understand project structure without expensive `find`, `tree`, or `ls -R` commands. Implementation lives in `scripts/init-smart-search.sh` (64 lines) and is invoked by `tokenso save`, `tokenso install`, and `tokenso map`.

## Invocation

```bash
tokenso map                                  # view colorized map with token estimate
tokenso save                                 # regenerate map + update stats + state.md
tokenso save --silent                        # regenerate silently (no output)
tokenso save "milestone note"                # regenerate + log milestone
tokenso install                              # generates initial map during setup
bash .ai-memory/scripts/init-smart-search.sh .  # direct script invocation
```

## Map Output

Stored at `.ai-memory/repo-map.txt`. A tiny compressed tree (~20 lines for most projects):

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

From `scripts/init-smart-search.sh`:

### Primary: `tree`
```bash
tree -I "$EXCLUDES" --dirsfirst -F
```

### Fallback: `find`
```bash
find . -not -path "*/$EXCLUDES/*" -not -name "$EXCLUDES" | sort
```

## Exclusion Patterns

Defined at `bin/tokenso:92-93` — shared by `rg` and `find` paths to prevent drift:

**Excluded directories:**
```
.ai-memory .git node_modules build dist .dart_tool Pods .gradle
.venv venv __pycache__ .idea .vscode .expo .next .nuxt out
coverage .nyc_output target .cargo
```

**Excluded file extensions:**
```
.png .jpg .jpeg .gif .ico .pdf .zip .gz .tar .mp4 .mp3
.woff .woff2 .ttf .eot .map .lock .db .exe .dll .so
.dylib .class .jar .apk .ipa .bundle
```

The `list_source_files()` function (`bin/tokenso:95-105`) applies these via:
```bash
EXCLUDE_FILE_PATTERN='\.(png|jpg|jpeg|gif|...)$'
EXCLUDE_DIR_PATTERN='(^|/)(\.git|node_modules|build|...)(/|$)'
```

## Token Estimation Formula

From `run_save()` at `bin/tokenso:656-658`:

```bash
raw_tokens=$(( raw_words * 13 / 10 ))     # full scan estimate
map_tokens=$(( map_words * 13 / 10 ))      # map estimate
saved_tokens=$(( raw_tokens - map_tokens ))
```

The 13/10 ratio (1.3 tokens per word) is used consistently. The stats dashboard displays the savings.

## Map Lifecycle

1. **Initial creation:** `tokenso install` runs `bash .ai-memory/scripts/init-smart-search.sh .`.
2. **Refresh:** `tokenso save` regenerates the map each time (overwrites `.ai-memory/repo-map.txt`).
3. **View:** `tokenso map` displays the map with colorized output and token weight estimate.
4. **Clean:** `tokenso clean` deletes `.ai-memory/repo-map.txt` along with all other `.ai-memory/` contents.
5. **Auto-recover:** If `.ai-memory/scripts/init-smart-search.sh` is missing when `tokenso save` runs, it copies from `scripts/` or downloads from GitHub.

## Script Copying

During `tokenso install`:
```bash
# Local copy available (from repo)
cp scripts/init-smart-search.sh .ai-memory/scripts/init-smart-search.sh

# No local copy (remote install)
curl -sSL "https://raw.githubusercontent.com/.../scripts/init-smart-search.sh" \
  -o .ai-memory/scripts/init-smart-search.sh
```

The script is self-contained at 64 lines and has no dependencies beyond `tree` (preferred) or `find` (fallback).

## Staleness Detection

Check if the map is outdated:

```bash
# Find files newer than the map
find . -newer .ai-memory/repo-map.txt \
  -not -path "./.git/*" \
  -not -path "./node_modules/*" \
  -not -path "./.ai-memory/*" | head -5
```

If any files are found, the map is stale — run `tokenso save` to refresh.

## Integration with Other Commands

| Command | Map Interaction |
|---------|----------------|
| `tokenso map` | Displays the map with syntax highlighting |
| `tokenso save` | Regenerates map, calculates token savings, updates stats |
| `tokenso install` | Generates initial map |
| `tokenso search` | Uses map for fuzzy path matching (Pass 1 of search) |
| `tokenso clean` | Deletes the map |
| `tokenso state` | Reads state.md (not the map, but co-located in `.ai-memory/`) |

## Best Practices

- Regenerate after structural changes (new dirs, renamed files).
- Keep map under 50 lines — if larger, add more exclusions to `EXCLUDE_DIR_PATTERN`.
- `.ai-memory/` is gitignored — map regenerates per-machine per-project.
- The map is consumed by `tokenso search` as a fast path index — keeping it fresh improves search quality.
