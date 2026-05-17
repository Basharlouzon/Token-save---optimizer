# Cross-Agent Rule Injector

Inject Tokenso optimizer rules into AI tool configuration files across 16+ supported tools. Use when setting up Tokenso in a new project or updating rules after a Tokenso upgrade.

## Overview

The cross-agent injector ensures that Tokenso's search diet, smart init, and memory protocol rules are present in every AI tool config file in the project. It uses versioned markers so re-running safely updates rules without duplication.

## Supported Tools

| Tool | Config File | Format |
|------|------------|--------|
| Claude Code | `CLAUDE.md`, `.claudecode` | Markdown |
| Cline | `.clinerules` | Plain text |
| Roo | `.roorules` | Plain text |
| Kilo | `.kilorules` | Plain text |
| Gemini CLI / Antigravity | `.geminirules` | Plain text |
| Open Code | `.opencoderules` | Plain text |
| Aider | `.aider.conf.yml` (conventions section) | YAML |
| Continue.dev | `.continuerules` | Plain text |
| Cursor | `.cursorrules` | Plain text |
| Windsurf | `.windsurfrules` | Plain text |
| Void | `.voidrules` | Plain text |
| Zed | `.zedrules` | Plain text |
| PearAI | `.pearai rules.md` | Markdown |
| GitHub Copilot | `.github/copilot-instructions.md` | Markdown |
| Amazon Q | `.amazonq/rules.md` | Markdown |
| Augment Code | `.augment-guidelines` | Plain text |

## Invocation

```bash
# Inject into all supported configs in the current project
bash scripts/apply-cross-rules.sh .

# Inject into a different project
bash scripts/apply-cross-rules.sh ../other-project

# From Tokenso install wizard
tokenso install   # interactive tool selection
```

## Versioned Markers

Rules are wrapped in unique markers with a version stamp:

```
# >>> tokenso-rules v1 >>>
(Search diet rules)
(Semory protocol rules)
# <<< tokenso-rules v1 <<<
```

When `MARKER_VERSION` is bumped (e.g., `v1` → `v2`), re-running the script:

1. Detects the old marker block.
2. Replaces it with the new version's rules.
3. Preserves any user content outside the markers.

This ensures idempotent, safe re-application.

## Rule Template

The standard Tokenso rules injected into all tools:

```
- **Search Diet**: Do not read full files blindly. Check file size first. Use lightweight search to find filenames before reading. Only read specific line ranges required.
- **Smart Init**: If you need to explore the project, do not run `ls -R`. Instead, run `bash .ai-memory/scripts/init-smart-search.sh .` and read `.ai-memory/repo-map.txt`.
- **Memory Protocol**: Before acting, always read `.ai-memory/state.md`. Upon reaching a milestone or repeating actions, compress your current understanding into `.ai-memory/state.md` and explicitly command yourself to forget the prior raw context to save tokens.
- **Stop Duplication**: If you find yourself in a loop or re-reading the same files, STOP. Update the memory state and ask the user for clarification.
```

## Adding a New Tool

To add support for a new AI tool:

1. Open `scripts/apply-cross-rules.sh`.
2. Add a new function following the existing pattern:

```bash
inject_newtool() {
    local dir=$1
    local file="$dir/.newtoolrules"
    inject_with_markers "$file" "tokenso-rules" "$MARKER_VERSION" "$RULES_BLOCK"
}
```

3. Add the tool to the `inject_all()` function.
4. Test: `bash scripts/apply-cross-rules.sh .`
5. Verify the file was created with correct markers.

## Dry-Run Mode

To preview changes without modifying files, add a dry-run check in the injector:

```bash
if [ "$DRY_RUN" = true ]; then
    echo "Would inject into: $file"
    return 0
fi
```

Then run: `DRY_RUN=true bash scripts/apply-cross-rules.sh .`

## Selective Injection

The `tokenso install` wizard lets users pick specific tools interactively. For programmatic selective injection, modify the script to accept tool names as arguments:

```bash
bash scripts/apply-cross-rules.sh . --tools claude,kilo,gemini
```

## Verification

After injection, verify rules are present:

```bash
# Check all config files for tokenso markers
rg "tokenso-rules" . --glob '.*rules' --glob 'CLAUDE.md' --glob '.claudecode'
```
