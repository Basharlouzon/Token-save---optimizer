---
name: brainstorming
description: "You MUST use this before any creative work — creating features, building components, adding functionality, or modifying behavior. Explores intent, requirements, and design before implementation."
---

# Brainstorming Ideas Into Designs

Turn ideas into approved designs through short, focused dialogue.

## Hard gate

<HARD-GATE>
No code, no scaffolding, no implementation until a design is presented AND the user has explicitly approved it. This applies regardless of perceived simplicity. A design can be three sentences for truly small work, but it must exist and be approved.
</HARD-GATE>

## Rapid Mode (Trivial Changes)

For genuinely trivial changes (< 5 lines, single-file, no architectural impact):

1. State the change in one sentence.
2. Ask: "This is a trivial change — proceed directly?"
3. If yes, implement. If no, use the full flow.

Do not abuse rapid mode.

## Scope Estimation Heuristic

| Scope | Signal | Flow |
|-------|--------|------|
| Trivial | < 5 lines, 1 location | Rapid mode |
| Small | 1 function, < 50 lines | 3-sentence design → approval → implement |
| Medium | Multiple files, new feature | Full flow |
| Large | New subsystem | Decompose first, full flow per sub-project |

## Checklist

1. **Explore context.** Read `.ai-memory/state.md` first. Use `tokenso map` to understand structure cheaply. Read relevant files, docs, recent commits.
2. **Triage scope.** Decompose if request bundles multiple independent subsystems.
3. **Offer visual companion** (only if genuinely visual). Send as its own message.
4. **Ask clarifying questions** — one per message, prefer multiple-choice.
5. **Propose 2–3 approaches** with trade-offs. Lead with recommendation.
6. **Present design in sections.** Get approval after each.
7. **Write spec** to `docs/specs/YYYY-MM-DD-<topic>-design.md`. Commit.
8. **Self-review spec** — fix inline.
9. **Ask user to review.** Wait for approval.
10. **Checkpoint to Tokenso** — `tokenso save "Approved design: <topic>"`. Hand off to implementation.

## Design Anti-Patterns Checklist

- **Over-engineering** — abstraction not yet needed.
- **Scope creep** — YAGNI.
- **Premature abstraction** — interfaces for single implementation.
- **Unknown unknowns** — can't explain a part? Say so.
- **Copy-paste design** — patterns from other projects without adaptation.
- **Ignored existing conventions** — read surrounding code first.

## Asking clarifying questions

- One per message.
- Multiple-choice when possible.
- Focus on the gap — don't ask what the project already answers.
- Open-ended only when option space is genuinely unknown.

## Proposing approaches

- 2–3 options max. State recommendation first.
- If one approach is obviously right, say so.

## Presenting the design

Cover these, scaled to complexity:

- **Architecture** — the shape.
- **Components** — one purpose each, defined interface.
- **Data flow** — what moves where.
- **Error handling** — what fails, what happens.
- **Testing** — how we verify.

Approve section-by-section. 200–300 words upper bound for nuanced sections.

### Design for isolation

For each unit: **what does it do, how do you use it, what does it depend on?** If you can't answer in one sentence, split it.

### Working in existing codebases

- Read surrounding code first. Follow existing patterns.
- Include targeted fixes for blocking code — no unrelated refactoring.

## Spec self-review

After writing:

1. **Placeholders** — resolve `TBD`, `TODO`, vagueness.
2. **Internal consistency** — sections agree.
3. **Scope** — single-plan sized.
4. **Ambiguity** — pick one interpretation, make it explicit.

Then: "Spec written and committed to `<path>`. Please review before implementation."

## Checkpoint to Tokenso

After approval:

```bash
tokenso save "Approved design: <topic>"
```

Records milestone in `.ai-memory/state.md` + updates token stats.

## Visual companion

Offer only when questions are genuinely visual. Send as its own message:

> Some of what we're working on might be easier to explain with mockups or diagrams. Want to try? (Requires opening a local URL)

Decide per question whether visual beats text.

## Key principles

- One question at a time.
- YAGNI ruthlessly.
- Lead with recommendation. Reasoning second.
- Validate incrementally — approve sections, not walls of text.
- Be willing to back up if later questions invalidate earlier premises.
