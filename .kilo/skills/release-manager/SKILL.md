# Release Manager

Manage version bumps, changelogs, git tags, and GitHub releases for the Tokenso project.

## Version Scheme

Tokenso uses semver (`MAJOR.MINOR.PATCH`). Version is defined at `bin/tokenso:8`:

```bash
VERSION="2.2.0"
```

- **PATCH** — bug fixes, install script fixes, small improvements.
- **MINOR** — new commands, new features, backward-compatible changes.
- **MAJOR** — breaking changes to CLI interface or config format.

## Pre-Release Checklist

1. **Clean tree.** `git status` — no uncommitted changes.
2. **All pushed.** `git log origin/master..HEAD` — no unpushed commits.
3. **README current.** Version badge, "What's new" section, command table match reality.
4. **Install script works.** Test the curl | bash flow:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/install.sh | bash
   ```
5. **Smoke test.** `tokenso map`, `tokenso state`, `tokenso search "test"`, `tokenso stats` all run without errors.
6. **Cross-agent injection works.** `bash scripts/apply-cross-rules.sh .` runs clean.

## Release Process

### Step 1: Version Bump

Edit `bin/tokenso` line 8:
```bash
VERSION="X.Y.Z"
```

### Step 2: Update README

- Update the version badge at line 3: `version-X.Y.Z`
- Add/update the "What's new in X.Y.Z" section at line 15.
- Verify the command table (line 240+) is current.

### Step 3: Generate Changelog

```bash
LAST_TAG=$(git describe --tags --abbrev=0)
git log "$LAST_TAG"..HEAD --pretty=format:"- %s"
```

### Step 4: Commit

```bash
git add bin/tokenso README.md
git commit -m "Bump version to X.Y.Z"
```

### Step 5: Tag

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z

## What's New
- Feature descriptions

## Fixes
- Bug fix descriptions"
```

### Step 6: Push

```bash
git push origin master
git push origin vX.Y.Z
```

### Step 7: GitHub Release

```bash
gh release create vX.Y.Z \
  --title "vX.Y.Z" \
  --notes "## What's New
- Features

## Installation
\`\`\`bash
curl -fsSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/install.sh | bash
\`\`\`"
```

### Step 8: Post-Release

Bump to next `-dev` version in `bin/tokenso` and push:

```bash
# Edit VERSION="X.Y.(Z+1)-dev"
git commit -m "Prepare for next development iteration"
git push origin master
```

## Conventional Commits

| Prefix | Changelog Section |
|--------|------------------|
| `feat:` | Features |
| `fix:` | Bug Fixes |
| `docs:` | Documentation |
| `refactor:` | Refactoring |
| `perf:` | Performance |
| `test:` | Tests |
| `chore:` | Maintenance |

## Files That Reference Version

| File | Location |
|------|----------|
| `bin/tokenso` | Line 8: `VERSION="2.2.0"` |
| `README.md` | Line 3: version badge |
| `.ai-memory/optimizer-stats.json` | Auto-updated by `tokenso save` |
| Install script output | Displays version during install |

## Rollback

```bash
git push origin :refs/tags/vX.Y.Z      # delete remote tag
gh release delete vX.Y.Z               # delete GitHub release
git revert <commit-hash>               # revert version bump
git push origin master
```

## Tokenso-Specific Notes

- The install script downloads from `master` branch — pushed changes go live immediately.
- The `tokenso update` command self-updates from GitHub master.
- Always test install after changes to `install.sh` or `bin/tokenso`.
- `apply-cross-rules.sh` has `MARKER_VERSION="v1"` — bump if rules text changes.
