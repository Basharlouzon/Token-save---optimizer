---
name: release-manager
description: "Use when preparing a new version release. Handles version bumping, changelog generation, git tagging, and GitHub release creation for the Tokenso project."
---

# Release Manager

Manage version bumps, changelogs, git tags, and GitHub releases.

## Version Scheme

Semantic versioning (`MAJOR.MINOR.PATCH`):

- **PATCH**: Bug fixes, small improvements.
- **MINOR**: New commands, backward-compatible features.
- **MAJOR**: Breaking changes to CLI or config format.

Version is defined in `bin/tokenso` at the `VERSION=` line.

## Pre-Release Checklist

1. `git status` — working tree clean.
2. `git log origin/master..HEAD` — all commits pushed.
3. README version references match.
4. Install script tested: `curl -fsSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/install.sh | bash`

## Release Process

### Step 1: Version Bump
```bash
rg -n 'VERSION=' bin/tokenso
# Edit to new version
```

### Step 2: Generate Changelog
```bash
git describe --tags --abbrev=0          # last tag
git log <last-tag>..HEAD --pretty=format:"- %s"
```

### Step 3: Commit
```bash
git add bin/tokenso
git commit -m "Bump version to X.Y.Z"
```

### Step 4: Tag
```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z

## What's New
- Feature 1

## Fixes
- Bug fix 1"
```

### Step 5: Push
```bash
git push origin master
git push origin vX.Y.Z
```

### Step 6: GitHub Release
```bash
gh release create vX.Y.Z \
  --title "vX.Y.Z" \
  --notes "## What's New
- Feature 1

## Installation
\`\`\`bash
curl -fsSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/install.sh | bash
\`\`\`"
```

### Step 7: Post-Release
Bump to next `-dev` version and push.

## Conventional Commits

| Prefix | Section |
|--------|---------|
| `feat:` | Features |
| `fix:` | Bug Fixes |
| `docs:` | Documentation |
| `refactor:` | Refactoring |
| `perf:` | Performance |
| `chore:` | Maintenance |

## Rollback

```bash
git push origin :refs/tags/vX.Y.Z
gh release delete vX.Y.Z
git revert <commit-hash>
git push origin master
```
