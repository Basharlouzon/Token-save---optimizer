---
name: cross-agent-injector
description: "Use when setting up Tokenso in a new project or updating rules after an upgrade. Injects optimizer rules into 16+ AI tool config files with versioned markers for safe re-application."
---

# Cross-Agent Rule Injector

Inject Tokenso optimizer rules into AI tool configuration files across 16+ supported tools.

## Supported Tools

| Tool | Config File |
|------|------------|
| Claude Code | `CLAUDE.md`, `.claudecode` |
| Cline | `.clinerules` |
| Roo | `.roorules` |
| Kilo | `.kilorules` |
| Gemini CLI | `.geminirules` |
| Open Code | `.opencoderules` |
| Aider | `.aider.conf.yml` |
| Continue.dev | `.continuerules` |
| Cursor | `.cursorrules` |
| Windsurf | `.windsurfrules` |
| Void | `.voidrules` |
| Zed | `.zedrules` |
| PearAI | `.pearai rules.md` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Amazon Q | `.amazonq/rules.md` |
| Augment Code | `.augment-guidelines` |

## Invocation

```bash
bash scripts/apply-cross-rules.sh .            # current project
bash scripts/apply-cross-rules.sh ../other-app # different project
tokenso install                                # interactive wizard
```

## Versioned Markers

Rules wrapped in unique markers with version stamp:

```
# >>> tokenso-rules v1 >>>
(rules)
# <<< tokenso-rules v1 <<<
```

When `MARKER_VERSION` bumps, re-running replaces old blocks with new rules. Idempotent and safe.

## Rule Template

```
- **Search Diet**: Do not read full files blindly. Check file size first. Use lightweight search to find filenames before reading. Only read specific line ranges required.
- **Smart Init**: If you need to explore the project, do not run `ls -R`. Instead, run `bash .ai-memory/scripts/init-smart-search.sh .` and read `.ai-memory/repo-map.txt`.
- **Memory Protocol**: Before acting, always read `.ai-memory/state.md`. Upon reaching a milestone or repeating actions, compress your understanding into `.ai-memory/state.md` and explicitly command yourself to forget the prior raw context.
- **Stop Duplication**: If you find yourself in a loop or re-reading the same files, STOP. Update the memory state and ask the user for clarification.
```

## Adding a New Tool

1. Open `scripts/apply-cross-rules.sh`.
2. Add inject function following existing pattern.
3. Add to `inject_all()`.
4. Test: `bash scripts/apply-cross-rules.sh .`

## Dry-Run

```bash
DRY_RUN=true bash scripts/apply-cross-rules.sh .
```

## Verification

```bash
rg "tokenso-rules" . --glob '.*rules' --glob 'CLAUDE.md' --glob '.claudecode'
```
