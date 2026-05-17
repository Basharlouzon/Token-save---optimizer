---
name: release-manager
description: "Use when preparing a new version release. Handles version bumping, changelog generation, git tagging, and GitHub release creation."
---

# Release Manager

## Version Location

`bin/tokenso` line 8: `VERSION="2.2.0"`

## Pre-Release Checklist

1. `git status` — clean tree.
2. `git log origin/master..HEAD` — all pushed.
3. README version badge (line 3) + "What's new" section current.
4. Install script tested.
5. Smoke test: `tokenso map`, `tokenso state`, `tokenso search "test"`, `tokenso stats`.
6. `bash scripts/apply-cross-rules.sh .` runs clean.

## Process

### 1. Version Bump
Edit `bin/tokenso:8` → `VERSION="X.Y.Z"`

### 2. Update README
- Line 3: version badge → `version-X.Y.Z`
- Line 15: "What's new in X.Y.Z" section

### 3. Changelog
```bash
LAST_TAG=$(git describe --tags --abbrev=0)
git log "$LAST_TAG"..HEAD --pretty=format:"- %s"
```

### 4. Commit + Tag
```bash
git add bin/tokenso README.md
git commit -m "Bump version to X.Y.Z"
git tag -a vX.Y.Z -m "Release vX.Y.Z

## What's New
- ...

## Fixes
- ..."
```

### 5. Push + Release
```bash
git push origin master
git push origin vX.Y.Z
gh release create vX.Y.Z --title "vX.Y.Z" --notes "..."
```

### 6. Post-Release
Bump to `-dev` version and push.

## Conventional Commits

`feat:` `fix:` `docs:` `refactor:` `perf:` `test:` `chore:`

## Files Referencing Version

| File | Location |
|------|----------|
| `bin/tokenso` | Line 8 |
| `README.md` | Line 3 (badge) |
| `.ai-memory/optimizer-stats.json` | Auto-updated |

## Rollback

```bash
git push origin :refs/tags/vX.Y.Z
gh release delete vX.Y.Z
git revert <hash>
git push origin master
```

## Notes

- Install script downloads from `master` — changes go live immediately.
- `tokenso update` self-updates from GitHub master.
- `MARKER_VERSION="v1"` in `apply-cross-rules.sh` — bump if rules text changes.
