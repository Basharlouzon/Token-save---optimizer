# ADR-0003: Atomic self-update for `tokenso update`

**Status:** Accepted
**Date:** 2026-05-18
**Version target:** v2.5.1

## Context

`tokenso update` (in `run_update()`) historically did:

```bash
curl -sSL "$REMOTE_URL" -o "$cmd_path"
chmod +x "$cmd_path"
```

This writes directly over the running binary on PATH. Any interruption mid-download — Ctrl+C, network drop, DNS hiccup, redirected to an HTML error page — leaves a **truncated** tokenso on disk. Symptom in the wild:

```
/Users/.../tokenso: line 393: unexpected EOF while looking for matching `}'
/Users/.../tokenso: line 394: syntax error: unexpected end of file
```

Once that happens the user can't even run `tokenso update` to recover, because the broken binary fails to parse before reaching `run_update()`. They have to fall back to a manual `curl`.

The standalone `install.sh` already does this correctly (download to temp, validate, `install(1)`); the in-process updater had been left behind.

## Decision

`run_update()` downloads to `mktemp`, validates payload (size + shebang + `bash -n`), then atomically replaces the live binary via `install(1)` (fallback: `mv`). On any failure path, the existing binary stays in place.

## Options Considered

### Option A — Temp file + validate + atomic replace (chosen)
| Dimension | Score | Note |
|-----------|-------|------|
| Token cost | None | Internal change |
| Bash portability | High | `mktemp -t`, `install`, `mv` all portable; `install` has `mv` fallback |
| Dependencies | None | Already require `curl`; nothing new |
| Cross-tool reach | Critical | This bug bricks tokenso for any user who Ctrl+Cs an update |
| Install surface | None | `install.sh` already does this; we're parity-fixing the in-process path |
| Migration cost | Zero | Same external behavior on the happy path |
| Reversibility | High | Pure replacement of one function |

**Pros:** Eliminates the entire class of partial-write corruptions. Network/payload errors now leave the binary untouched. Matches `install.sh` behavior.
**Cons:** ~40 more lines of bash; need to be careful with traps so the temp file doesn't persist.

### Option B — Write to sibling `.new`, then `mv` (simpler)
Skip `mktemp`; write to `${cmd_path}.new`.

**Pros:** Shorter.
**Cons:** If `$install_dir` isn't writable, we silently fall through to sudo with weird relative paths. `mktemp` gives us a guaranteed-writable place to fail fast.

### Option C — Leave it; document the gotcha
**Pros:** No code change.
**Cons:** The failure mode bricks the user's tokenso. Documentation doesn't help once the binary is unparseable.

## Trade-off

Option A is the only one that makes the failure mode *actually* recoverable: any error now leaves the previous tokenso intact, so the user can read the error, fix their network, and try again. Option B is fine but trades a tiny amount of clarity for no real win. Option C ignores the actual user pain (Bashar himself just hit it on his MacBook Pro).

## Consequences

- Easier: Ctrl+C, network drops, and bad payloads can no longer brick the install.
- Harder: `run_update()` is now ~90 lines, but the logic is linear and each guard is one-liner.
- Revisit when: we want signed releases — at that point add a `cosign verify` step after the syntax check.

## Action Items
- [x] Rewrite `run_update()` in `bin/tokenso` with download-to-temp + validate + atomic replace.
- [x] Trap `INT/TERM/HUP/EXIT` to clean up the temp file on abort.
- [x] Validate payload: size ≥ 10KB, starts with `#!/bin/bash`, passes `bash -n`.
- [x] Bump VERSION to 2.5.1 (patch — bug fix).
- [x] README "What's new" with recovery instructions for users hit by v2.5.0.
- [ ] Future: add `cosign verify` once releases are signed.
