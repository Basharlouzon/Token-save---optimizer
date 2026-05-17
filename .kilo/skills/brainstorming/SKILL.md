# Brainstorming Ideas Into Designs

Turn ideas into approved designs through short, focused dialogue. The terminal state is a committed, self-reviewed design spec ready for implementation.

## Hard Gate

No code, no scaffolding, no implementation until a design is presented AND approved by the user. This applies regardless of perceived simplicity. A design can be three sentences for truly small work, but it must exist and be approved.

## Rapid Mode (Trivial Changes)

For changes that are genuinely trivial (estimated < 5 lines, single-file, no architectural impact):

1. State the change in one sentence.
2. Ask: "This is a trivial change — proceed directly?"
3. If yes, implement. If no, use the full flow.

Do not abuse rapid mode. When in doubt, use the full flow.

## Scope Estimation Heuristic

| Scope | Signal | Flow |
|-------|--------|------|
| Trivial | < 5 lines, single location | Rapid mode |
| Small | 1 function, < 50 lines, 1 file | Abbreviated: 3-sentence design → approval → implement |
| Medium | Multiple files, new feature | Full flow |
| Large | New subsystem, cross-cutting | Decompose first, then full flow per sub-project |

## Checklist

1. **Explore project context.** Read `.ai-memory/state.md` first (if it exists), then relevant files, docs, recent commits. Use `tokenso map` to understand structure cheaply.
2. **Triage scope** using the heuristic above. Decompose if the request bundles multiple independent subsystems.
3. **Offer visual companion** (only if upcoming questions are genuinely visual). Send as its own message.
4. **Ask clarifying questions** — one per message, prefer multiple-choice, focus on purpose / constraints / success criteria.
5. **Propose 2–3 approaches** with trade-offs. Lead with your recommendation.
6. **Present the design in sections.** Get approval after each section.
7. **Write the spec** to `docs/specs/YYYY-MM-DD-<topic>-design.md` (or user's preferred location). Commit it.
8. **Self-review the spec** — fix inline.
9. **Ask the user to review.** Wait for approval.
10. **Checkpoint to Tokenso** — `tokenso save "Approved design: <topic>"`. Hand off to implementation.

## Design Anti-Patterns Checklist

- **Over-engineering** — abstraction layers or extensibility not yet needed.
- **Scope creep** — design growing beyond the original request. YAGNI.
- **Premature abstraction** — interfaces for a single implementation.
- **Unknown unknowns** — can't explain a part? Say so.
- **Copy-paste design** — patterns from other projects without adaptation.
- **Ignored existing conventions** — always read surrounding code first.

## Asking Clarifying Questions

- One per message. Multiple dilute the answer.
- Multiple-choice when possible.
- Focus on the gap — don't ask what the project state already answers.
- Open-ended is fine when the option space is genuinely unknown.

## Proposing Approaches

- 2–3 options maximum.
- State recommendation first, then explain.
- If one approach is obviously right, say so.

## Presenting the Design

Cover these, scaled to complexity:

- **Architecture** — the shape of the thing.
- **Components / units** — one clear purpose each, defined interface, independently testable.
- **Data flow** — what moves where, and when.
- **Error handling** — what can fail, what happens.
- **Testing** — how we verify.

A few sentences each is fine. 200–300 words upper bound for genuinely nuanced sections. Approve section-by-section.

### Design for Isolation

For each unit: **what does it do, how do you use it, what does it depend on?** If you can't answer in one sentence, split it.

### Working in Existing Codebases

- Read surrounding code first. Follow existing patterns.
- If existing code blocks the work, include the targeted fix as part of this design.
- Do not propose unrelated refactoring.

## Spec Self-Review

After writing:

1. **Placeholders** — resolve any `TBD`, `TODO`, or vagueness.
2. **Internal consistency** — sections agree with each other.
3. **Scope** — single-plan sized, or needs decomposition.
4. **Ambiguity** — pick one interpretation and make it explicit.

Then: "Spec written and committed to `<path>`. Please review before we start implementation."

## Checkpoint to Tokenso

After design approval:

```bash
tokenso save "Approved design: <topic>"
```

Records the milestone in `.ai-memory/state.md` and updates cumulative token stats.

## Visual Companion

Offer only when questions are genuinely visual. The offer is its own message:

> Some of what we're working on might be easier to explain with mockups or diagrams in a browser. Want to try? (Requires opening a local URL)

After acceptance, decide per question whether visual is better than text. If not, stay in terminal.

## Key Principles

- One question at a time.
- YAGNI ruthlessly.
- Lead with recommendation. Reasoning second.
- Validate incrementally — approve sections, not walls of text.
- Be willing to back up if later questions invalidate earlier premises.
