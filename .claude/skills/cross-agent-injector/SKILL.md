---
name: cross-agent-injector
description: "Use when setting up Tokenso in a new project or updating rules. Injects optimizer rules into 16+ AI tool config files with versioned markers."
---

# Cross-Agent Rule Injector

Implementation: `scripts/apply-cross-rules.sh` (78 lines) + `run_install()` in `bin/tokenso:396-572`.

## Supported Tools (16 + Antigravity global)

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
| 9 | Cursor | `.cursorrules` + `.cursor/rules/token-optimizer.mdc` |
| 10 | Windsurf | `.windsurfrules` |
| 11 | Void Editor | `.voidrules` |
| 12 | Zed AI | `.zed/assistant-rules.md` |
| 13 | PearAI | `.pearai` |
| 14 | GitHub Copilot | `.github/copilot-instructions.md` |
| 15 | Amazon Q | `.amazonq/rules/token-optimizer.md` |
| 16 | Antigravity | `~/.gemini/antigravity/skills/context-optimizer/SKILL.md` + `.geminirules` |

## Invocation

```bash
bash scripts/apply-cross-rules.sh .            # all tools
bash scripts/apply-cross-rules.sh ../other     # different project
tokenso install                                # interactive wizard
tokenso install 1 4 5                          # non-interactive (Claude, Kilo, Gemini)
```

## Versioned Markers

```bash
MARKER_VERSION="v1"  # in apply-cross-rules.sh:11
MARKER="TOKENSO CONTEXT OPTIMIZER RULES ($MARKER_VERSION)"
```

- **Same version present** → skip ("already configured").
- **Version bumped** → old marker not matched, new rules appended.
- **Idempotent** — re-running never duplicates.

## Rule Template

4 rules injected: Search Diet, Smart Init, Memory Protocol, Stop Duplication. (See `apply-cross-rules.sh:13-22`.)

## Special Cases

- **Aider (#7)**: Also creates `.aider.conf.yml` with `read-only: .ai-memory/repo-map.txt`.
- **Cursor (#9)**: Creates both `.cursorrules` and `.cursor/rules/token-optimizer.mdc`.
- **Antigravity (#16)**: Global skill at `~/.gemini/antigravity/skills/context-optimizer/`.
- **Continue.dev (#8)**: Creates `.continue/` directory.
- **Amazon Q (#15)**: Creates `.amazonq/rules/` directory.

## Adding a New Tool

1. Add `inject_rules` call in `apply-cross-rules.sh`.
2. Add case in `run_install()` loop (`bin/tokenso:480-541`).
3. Add detection in `detect_tools()` (`bin/tokenso:67-88`).
4. Add to wizard menu.
5. Test both `apply-cross-rules.sh` and `tokenso install`.

## Verification

```bash
rg "TOKENSO CONTEXT OPTIMIZER RULES" . --glob '.*rules' --glob 'CLAUDE.md' --glob '.claudecode'
```
