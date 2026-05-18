---
name: architecture
description: "Use when making a non-trivial design decision in Tokenso — choosing a tool/approach, adding a subsystem, changing data formats, or proposing a refactor. Produces an ADR in docs/adr/ with options, trade-offs, and consequences."
---

# Architecture — ADR & System Design for Tokenso

## When to Trigger

| Situation | Use this skill? |
|-----------|-----------------|
| Adding a new top-level CLI command | Yes |
| Changing `.ai-memory/` file format or location | Yes |
| Picking between two libraries / dependencies | Yes |
| Refactoring how `tokenso search` ranks results | Yes |
| Renaming a flag or bumping marker version | Yes (light ADR) |
| Cosmetic / typo / docs-only edit | No |
| Bug fix with one obvious cause | No |

If unsure, write the ADR. A 10-minute ADR beats a 10-hour rewrite.

## Three Modes

| Mode | Use when | Output |
|------|----------|--------|
| **Decide** | Two+ viable options exist | New ADR with chosen option |
| **Evaluate** | Reviewing a proposed design | ADR-style review with risks + recommendation |
| **Design** | Building something new from requirements | Component sketch + ADR for key choices |

## Workflow

1. **Frame the decision** — one sentence: "Should we X or Y, given constraint Z?"
2. **List constraints** upfront: token budget, bash-only, no daemons, cross-tool compatibility, install-script-distributed.
3. **Generate 2–3 options** — never just one. Force the alternative even if you're leaning one way.
4. **Score each** on the dimensions table below.
5. **Pick + justify** in 3 bullets.
6. **Write `docs/adr/NNNN-slug.md`** using the template.
7. **Add to `.ai-memory/state.md`** under "Key Context & Architecture" — one line, link to ADR.

## Scoring Dimensions (Tokenso-specific)

| Dimension | What to ask |
|-----------|-------------|
| **Token cost** | Does this make agents read more or fewer tokens? |
| **Bash portability** | Works on macOS bash 3.2 + Linux bash 5.x? No GNU-only flags? |
| **Dependencies** | New binary required? Optional fallback? `rg → grep` style? |
| **Cross-tool reach** | Affects all 16+ AI tools or just one? |
| **Install surface** | Does `install.sh` need changes? Does `tokenso update` still work? |
| **Migration cost** | Existing users' `.ai-memory/` still valid? |
| **Reversibility** | Can we undo this in one release? |

## ADR Template (`docs/adr/NNNN-slug.md`)

```markdown
# ADR-NNNN: <Title>

**Status:** Proposed | Accepted | Deprecated | Superseded by ADR-XXXX
**Date:** YYYY-MM-DD
**Version target:** vX.Y.Z

## Context
One paragraph. What forces are at play? What constraints?

## Decision
One sentence. Active voice. "We will …"

## Options Considered

### Option A — <Name>
| Dimension | Score | Note |
|-----------|-------|------|
| Token cost | Low/Med/High | … |
| Bash portability | … | … |
| Dependencies | … | … |
| Cross-tool reach | … | … |
| Install surface | … | … |
| Migration cost | … | … |
| Reversibility | … | … |

**Pros:** …
**Cons:** …

### Option B — <Name>
(same table)

## Trade-off
Two sentences. Why A beats B for *this* constraint set.

## Consequences
- Easier: …
- Harder: …
- Revisit when: …

## Action Items
- [ ] Code change in `bin/tokenso:<line>`
- [ ] Update `README.md` "What's new"
- [ ] Update `.claude/skills/<skill>/SKILL.md` if affected
- [ ] Bump version per `release-manager` skill
```

## Numbering

`ls docs/adr/ | tail -1` → next number. Pad to 4 digits: `0001`, `0002`, …

## Quick Decision Cheat Sheet

| Question | Default answer |
|----------|----------------|
| Add a daemon? | **No.** Tokenso is one-shot bash. |
| New runtime dependency? | **Only if optional with bash fallback.** |
| Break `.ai-memory/` schema? | **No** without migration path + version bump. |
| New top-level command? | **Yes** if it composes with existing ones. **No** if it duplicates. |
| Touch `apply-cross-rules.sh` marker? | Bump `MARKER_VERSION` in same commit. |

## Anti-Patterns

- **One-option ADRs** — no alternative considered means no real decision. Force at least one rival.
- **Future-proofing** — designing for traffic/scale Tokenso will never have. We're a CLI, not a service.
- **Hidden dependencies** — adding `jq`/`node`/`python` without `command -v` fallback breaks installs.
- **ADR after the fact** — write before merging. Retro-ADRs rot.
- **Vague status** — "Proposed" forever. Move to Accepted or Rejected within one release cycle.
- **Skipping `state.md`** — future sessions won't find the decision and will re-litigate it.

## Cross-References

- New feature exploration first? Use `superpowers:brainstorming`.
- Ready to ship the change? Use `release-manager`.
- Need to find prior decisions? `tokenso search "ADR"` then read `docs/adr/`.
