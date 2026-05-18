# ADR-0001: Adopt ADR Process for Tokenso

**Status:** Accepted
**Date:** 2026-05-18
**Version target:** v2.4.0

## Context

Tokenso has grown to 3258 lines of bash with 7 local skills and a multi-tool injection surface. Design decisions (memory file layout, search hierarchy, marker versioning, install path) live only in commit messages and code comments. New contributors and future sessions re-litigate settled questions because there is no durable record.

## Decision

We will keep lightweight ADRs in `docs/adr/NNNN-slug.md`, written through the `/architecture` skill, for every non-trivial design decision. Status moves from Proposed → Accepted (or Rejected) within one release cycle.

## Options Considered

### Option A — ADR files in `docs/adr/`
| Dimension | Score | Note |
|-----------|-------|------|
| Token cost | Low | Plain markdown, agent-searchable via `tokenso search` |
| Bash portability | N/A | Docs only |
| Dependencies | None | Just files |
| Cross-tool reach | High | Every AI tool can read them |
| Install surface | None | Doesn't ship via install.sh |
| Migration cost | Zero | New directory |
| Reversibility | Total | Delete the folder |

**Pros:** Greppable, versioned with code, no tooling.
**Cons:** Discipline-dependent.

### Option B — GitHub Issues / Discussions only
| Dimension | Score | Note |
|-----------|-------|------|
| Token cost | High | Requires GitHub API to surface to agents |
| Cross-tool reach | Low | Not in repo |
| Reversibility | Low | History scattered |

**Pros:** Comments + reactions.
**Cons:** Invisible to agents working locally; rots.

### Option C — Single `DECISIONS.md`
**Pros:** One file, easy to skim.
**Cons:** Merge conflicts, no per-decision status, hard to deprecate.

## Trade-off

Option A wins because Tokenso's whole thesis is "agents read the repo, not the network." ADRs as files keep decisions inside the agent's existing search hierarchy. Option B loses the moment the user is offline; Option C loses the moment two ADRs are in flight at once.

## Consequences

- Easier: future sessions find prior decisions via `tokenso search "ADR"`.
- Harder: contributors must remember to write the ADR — mitigated by `/architecture` skill prompt.
- Revisit when: ADR count exceeds ~30 and index becomes useful.

## Action Items
- [x] Create `docs/adr/` directory.
- [x] Ship `.claude/skills/architecture/SKILL.md`.
- [x] Add quick reference to `state.md`.
- [ ] Mention ADRs in `README.md` "What's new in 2.4.0".
