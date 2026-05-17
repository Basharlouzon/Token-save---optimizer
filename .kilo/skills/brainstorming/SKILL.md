# Brainstorming Ideas Into Designs

Turn ideas into approved designs through short, focused dialogue. The terminal state is a committed, self-reviewed design spec ready for implementation planning.

## Hard Gate

No code, no scaffolding, no implementation until a design is presented AND the user has explicitly approved it. This applies regardless of perceived simplicity. A todo list, a one-line config change, a "trivial" utility — all get a design. The design can be three sentences for truly small work, but it must exist and be approved.

## Rapid Mode (Trivial Changes)

For changes that are genuinely trivial (estimated < 5 lines, single-file, no architectural impact):

1. State the change in one sentence.
2. Ask: "This is a trivial change — proceed directly?"
3. If yes, implement. If no, fall back to the full flow.

**Do not abuse rapid mode.** When in doubt, use the full flow.

## Scope Estimation Heuristic

Before diving in, gauge scope:

- **Trivial** (< 5 lines, single location) → Rapid mode
- **Small** (1 function or component, < 50 lines) → Abbreviated flow (3-sentence design → approval → implement)
- **Medium** (multiple files, new feature) → Full flow below
- **Large** (new subsystem, cross-cutting concern) → Decompose first, then full flow per sub-project

## Checklist

1. **Explore project context** — read relevant files, docs, recent commits before asking anything.
2. **Triage scope** using the heuristic above. If the request bundles multiple independent subsystems, decompose it first. Each sub-project gets its own cycle.
3. **Offer visual companion** (only if upcoming questions are genuinely visual). Send the offer as its own message — no other content attached.
4. **Ask clarifying questions** — one per message, prefer multiple-choice, focus on purpose / constraints / success criteria.
5. **Propose 2–3 approaches** with trade-offs. Lead with your recommendation and explain why.
6. **Present the design in sections.** Scale each section to its complexity. Get approval after each section.
7. **Write the spec** to `docs/specs/YYYY-MM-DD-<topic>-design.md` (or the user's preferred location). Commit it.
8. **Self-review the spec** — fix inline, no second pass needed.
9. **Ask the user to review** the committed spec file. Wait for approval.
10. **Hand off to implementation** — only after explicit approval.

## Design Anti-Patterns Checklist

Watch for these traps during design:

- **Over-engineering** — adding abstraction layers, plugin systems, or extensibility points that aren't needed yet.
- **Scope creep** — the design keeps growing beyond the original request. YAGNI.
- **Premature abstraction** — creating interfaces or base classes for a single implementation.
- **Unknown unknowns** — if you can't explain how a part works, say so. Don't hand-wave.
- **Copy-paste design** — importing patterns from other projects without adapting to this codebase's conventions.

## Asking Clarifying Questions

- **One per message.** Multiple questions dilute the answer.
- **Multiple-choice when possible.** Easier to answer; surfaces options the user hadn't considered.
- **Focus on the gap.** Don't ask things the project state already answers — read the repo first.
- **No follow-up questions in the same message.**
- **Open-ended is fine** when the option space is genuinely unknown.

## Proposing Approaches

- 2–3 options, not more.
- Each option gets: what it is, the trade-off vs. others, when you'd pick it.
- State your recommendation first, then explain.
- If one approach is obviously right, say so — don't manufacture alternatives.

## Presenting the Design

Cover these, scaled to complexity:

- **Architecture** — the shape of the thing.
- **Components / units** — each with one clear purpose, defined interface, independent testability.
- **Data flow** — what moves where, and when.
- **Error handling** — what can fail, what happens when it does.
- **Testing** — how we'll know it works.

### Design for Isolation

For each unit, answer in one sentence: **what does it do, how do you use it, what does it depend on?** If you can't, the boundaries need work.

### Working in Existing Codebases

- Read surrounding code first. Follow existing patterns.
- If existing code blocks the work (file too large, tangled responsibilities), include the targeted fix as part of this design.
- Do not propose unrelated refactoring. Stay focused.

## Spec Self-Review

After writing, check:

1. **Placeholders** — any `TBD`, `TODO`, or vague requirements? Resolve them.
2. **Internal consistency** — sections agree with each other?
3. **Scope** — single-plan sized, or needs further decomposition?
4. **Ambiguity** — any requirement readable two ways? Pick one.

Then prompt the user:

> Spec written and committed to `<path>`. Please review it and let me know if you want changes before we start implementation.

## Checkpoint to Tokenso

After design approval, checkpoint the decision:

```bash
tokenso save "Approved design: <topic>"
```

This records the milestone in `.ai-memory/state.md` and updates stats.

## Key Principles

- **One question at a time.**
- **YAGNI ruthlessly** — strip speculative features from every design.
- **Lead with the recommendation.** Reasoning second.
- **Validate incrementally.** Approve sections, not whole walls of text.
- **Be willing to back up.** If a later question reveals the earlier premise was wrong, go back and fix it.
