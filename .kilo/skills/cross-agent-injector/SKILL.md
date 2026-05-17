# Cross-Agent Rule Injector

Inject Tokenso optimizer rules into AI tool configuration files across 16+ supported tools. Implementation lives in `scripts/apply-cross-rules.sh` and the `run_install()` function in `bin/tokenso:396-572`.

## Supported Tools (16 + Antigravity global)

### AI Coding Agents
| # | Tool | Config File(s) |
|---|------|---------------|
| 1 | Claude Code | `.claudecode` + `CLAUDE.md` |
| 2 | Cline | `.clinerules` |
| 3 | Roo Code | `.roomodes` |
| 4 | Kilo | `.kilorules` |
| 5 | Gemini CLI | `.geminirules` |
| 6 | Open Code | `.opencode` |
| 7 | Aider | `CONVENTIONS.md` + `.aider.conf.yml` |
| 8 | Continue.dev | `.continue/config.yaml` |

### AI-Powered Editors
| # | Tool | Config File(s) |
|---|------|---------------|
| 9 | Cursor | `.cursorrules` + `.cursor/rules/token-optimizer.mdc` |
| 10 | Windsurf | `.windsurfrules` |
| 11 | Void Editor | `.voidrules` |
| 12 | Zed AI | `.zed/assistant-rules.md` |
| 13 | PearAI | `.pearai` |

### Enterprise & Cloud
| # | Tool | Config File(s) |
|---|------|---------------|
| 14 | GitHub Copilot | `.github/copilot-instructions.md` |
| 15 | Amazon Q Developer | `.amazonq/rules/token-optimizer.md` |

### Global Skill
| # | Tool | Target |
|---|------|--------|
| 16 | Antigravity (Google DeepMind) | `~/.gemini/antigravity/skills/context-optimizer/SKILL.md` + `.geminirules` |

## Invocation

```bash
# Inject into ALL supported configs
bash scripts/apply-cross-rules.sh .

# Inject into a different project
bash scripts/apply-cross-rules.sh ../other-project

# Interactive wizard (select specific tools by number)
tokenso install
# Enter: 1 9 14  (Claude Code, Cursor, GitHub Copilot)
# Enter: 0       (ALL tools)

# Non-interactive install
tokenso install 1 4 5   # Claude Code, Kilo, Gemini CLI
```

## Versioned Markers

Rules are wrapped in markers with a version stamp (from `apply-cross-rules.sh:11`):

```bash
MARKER_VERSION="v1"
MARKER="TOKENSO CONTEXT OPTIMIZER RULES ($MARKER_VERSION)"
```

Behavior:
- **First run:** Creates config file with rules enclosed in markers.
- **Re-run (same version):** Detects existing marker, skips ("already configured").
- **Version bump:** Old marker not found → new rules appended. Old marker block should be manually removed.
- **Idempotent:** Re-running never duplicates content.

## Rule Template

The exact text injected (from `apply-cross-rules.sh:13-22` and `bin/tokenso:404-413`):

```

# ==========================================
# TOKENSO CONTEXT OPTIMIZER RULES (v1)
# ==========================================
- **Search Diet**: Do not read full files blindly. Check file size first. Use lightweight search to find filenames before reading. Only read specific line ranges required.
- **Smart Init**: If you need to explore the project, do not run `ls -R`. Instead, run `tokenso map` (or `bash .ai-memory/scripts/init-smart-search.sh .`) and read `.ai-memory/repo-map.txt`.
- **Memory Protocol**: Before acting, always read `.ai-memory/state.md`. Upon reaching a milestone or repeating actions, compress your current understanding into `.ai-memory/state.md` and explicitly command yourself to forget the prior raw context to save tokens.
- **Stop Duplication**: If you find yourself in a loop or re-reading the same files, STOP. Update the memory state and ask the user for clarification.
```

## Special Cases

### Aider (#7)
Also creates `.aider.conf.yml` with read-only access to `.ai-memory/repo-map.txt`:
```yaml
read-only:
  - .ai-memory/repo-map.txt
```

### Cursor (#9)
Creates both `.cursorrules` and `.cursor/rules/token-optimizer.mdc` (Cursor's new rules directory format).

### Antigravity (#16)
Installs a global skill to `~/.gemini/antigravity/skills/context-optimizer/SKILL.md` — active in every project, not just the current one. Also copies `init-smart-search.sh` to the global skill directory.

### Continue.dev (#8)
Creates the `.continue/` directory before injecting into `config.yaml`.

### Amazon Q (#15)
Creates `.amazonq/rules/` directory structure before injection.

## Adding a New Tool

1. Add the injection in two places:
   - `scripts/apply-cross-rules.sh` — add `inject_rules` call.
   - `bin/tokenso run_install()` — add a case in the `for choice in $selections` loop.
2. Add detection in `detect_tools()` at `bin/tokenso:67-88`.
3. Add to the wizard menu in `run_install()`.
4. Test: `bash scripts/apply-cross-rules.sh .` and `tokenso install`.

## Verification

```bash
# Check all config files for tokenso markers
rg "TOKENSO CONTEXT OPTIMIZER RULES" . \
  --glob '.*rules' \
  --glob 'CLAUDE.md' \
  --glob '.claudecode' \
  --glob '.opencode' \
  --glob '.pearai' \
  --glob '.cursor/rules/*'

# Check which tools are detected in current project
tokenso install   # shows "already configured" for each active tool
```

## Dry-Run

Not built-in, but can be simulated:

```bash
# Preview what files would be created
for f in .claudecode CLAUDE.md .clinerules .roomodes .kilorules .geminirules .opencode CONVENTIONS.md .cursorrules .windsurfrules .voidrules .pearai; do
  [ -f "$f" ] && echo "EXISTS: $f" || echo "WOULD CREATE: $f"
done
```
