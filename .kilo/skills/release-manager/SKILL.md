# Release Manager

Manage version bumps, changelogs, git tags, and GitHub releases for the Tokenso project. Use when preparing a new version for release.

## Version Scheme

Tokenso uses semantic versioning (`MAJOR.MINOR.PATCH`):

- **PATCH** (`2.2.0` → `2.2.1`): Bug fixes, install script fixes, small improvements.
- **MINOR** (`2.2.0` → `2.3.0`): New commands, new features, backward-compatible changes.
- **MAJOR** (`2.2.0` → `3.0.0`): Breaking changes to CLI interface or config format.

The current version is defined in `bin/tokenso` at the `VERSION=` line.

## Pre-Release Checklist

Before starting a release, verify:

1. **Working tree is clean.** `git status` shows no uncommitted changes.
2. **All changes are committed.** Review `git log origin/master..HEAD` for unpushed commits.
3. **Tests pass** (if applicable — this is a bash project, so manual smoke-test).
4. **README is current.** Version references and feature docs match reality.
5. **Install script works.** Test: `curl -fsSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/install.sh | bash`

## Release Process

### Step 1: Version Bump

Update the version string in `bin/tokenso`:

```bash
# Find the current version line
rg -n 'VERSION=' bin/tokenso

# Edit it to the new version (e.g., 2.2.0 → 2.3.0)
```

### Step 2: Generate Changelog

Create a changelog from commits since the last tag:

```bash
# Get the last tag
git describe --tags --abbrev=0

# Generate changelog from that tag to HEAD
git log --oneline <last-tag>..HEAD

# Or use conventional commits format
git log <last-tag>..HEAD --pretty=format:"- %s"
```

### Step 3: Commit the Version Bump

```bash
git add bin/tokenso
git commit -m "Bump version to X.Y.Z"
```

### Step 4: Create Git Tag

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z

## What's New
- Feature 1
- Feature 2

## Fixes
- Bug fix 1"
```

### Step 5: Push to Remote

```bash
git push origin master
git push origin vX.Y.Z
```

### Step 6: Create GitHub Release

```bash
gh release create vX.Y.Z \
  --title "vX.Y.Z" \
  --notes "## What's New
- Feature 1

## Fixes
- Bug fix 1

## Installation
\`\`\`bash
curl -fsSL https://raw.githubusercontent.com/Basharlouzon/Token-save---optimizer/master/install.sh | bash
\`\`\`"
```

### Step 7: Post-Release

Bump to the next development version:

```bash
# Update bin/tokenso VERSION to X.Y.(Z+1)-dev
# Commit: "Prepare for next development iteration"
git commit -m "Prepare for next development iteration"
git push origin master
```

## Conventional Commits

Follow these prefixes for automatic changelog generation:

| Prefix | Section in Changelog |
|--------|---------------------|
| `feat:` | Features |
| `fix:` | Bug Fixes |
| `docs:` | Documentation |
| `refactor:` | Refactoring |
| `perf:` | Performance |
| `test:` | Tests |
| `chore:` | Maintenance |
| `ci:` | CI/CD |

## Rollback

If a release has critical issues:

```bash
# Delete the remote tag
git push origin :refs/tags/vX.Y.Z

# Delete the GitHub release
gh release delete vX.Y.Z

# Revert the version bump commit
git revert <commit-hash>
git push origin master
```

## Tokenso-Specific Notes

- The version string appears in `bin/tokenso` only (line ~3: `VERSION="2.2.0"`).
- The README has a "What's new in X.Y.Z" section that should be updated for feature releases.
- The install script downloads from `master` branch, so the pushed binary is what users get immediately.
- Always test the install script after changes to `install.sh` or `bin/tokenso`.
