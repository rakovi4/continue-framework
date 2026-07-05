# Journey Summary Format

When to write a journey summary entry, and the strict format for scenario summaries and carryover entries. This file is the authority for both — `/handoff` writes entries, `/continue` reads them. See `.claude/guidelines/workflow-detail.md` — Resuming Across Conversations — for how summaries fit the workflow.

## When to Write

Append an entry only when one of the following happened during the conversation:

- A red-phase prediction did not match the actual outcome (failure type, message, or status differs)
- A discussion produced an agreement not captured in an ADR
- Existing code behaved unexpectedly during investigation
- An approach was tried and did not work — useful to not repeat
- A decision was made about how to handle an edge case
- A bug or quirk was discovered that future scenarios will encounter

If none of these fired, write nothing — create no file, append no line. "Nothing to record" is a valid, common outcome; an empty summary file is a smell that invites filler.

Never append routine progress that a future session can derive from progress.md, the commit, the test code, or the production code — "implemented per spec; tests passed", "refactored to extract helper", "added migration", "fixed compilation error after rename". If you cannot articulate something a future session would not derive from the artifacts, write nothing. See DON'T-WRITE Examples below.

`/handoff` runs many times per conversation — once each time the agent notices a trigger, plus a final sweep before `/clear`. It is idempotent: before appending, check the summary file for an entry already covering the same moment and skip it. Re-recording an already-captured trigger is a duplicate, not a new entry.

## Entry Header

Every entry starts with this heading — MANDATORY, exact format:

```
## {step-name} ({YYYY-MM-DD})
```

`step-name` matches the progress.md checkbox label (`red-usecase`, `green-adapter h2`, `align-design`). The date is required. If the conversation ran no work unit (discussion only), use the most recently completed step, or `discussion`.

**The header is the step and date — never the block type.** `## Codebase Quirk — initial load ignores PAGE_SIZE` is WRONG. `## green-frontend-api (2026-05-14)` is right. The block type is the *inner* structure of the entry (see below), not the heading.

## Length Limit

Keep it short. Each block field is one sentence — two at the very most. A block is at most 6 lines. An entry holds one block, or two if both are short; if more than two things are worth recording, the conversation covered more than one step — split into separate dated entries.

Use ONLY the fields listed for the block type. Do not add `How to apply`, `Root cause`, `Next steps`, `TODO`, or any other field. Forward-looking instructions ("fix this in green-frontend-api", "do not skip X") belong in progress.md, not here — a journey entry records what happened, it does not direct future work.

## Block Types

Pick the block type that matches what happened. If no block applies, write nothing — do not create or open the file.

### Prediction Mismatch

When the red-phase prediction did not match the actual failure.

```
**Expected:** {predicted exception type / status / message}
**Actual:** {actual exception type / status / message}
**Why:** {root cause — typically a code path that runs before the expected one}
**Resolution:** {what changed in the test setup so the expected path is reached}
```

### Decision

When a discussion produced an agreement not captured in an ADR.

```
**Decision:** {the agreement, one sentence}
**Why:** {the reason that justified it}
**Where applied:** {file, port, or component the decision affects}
```

### Surprise

When existing code behaved unexpectedly during investigation.

```
**Surprise:** {what surprised you}
**Why:** {underlying mechanism / invariant}
**Impact:** {what callers / future code must do because of this}
```

### Mistake Avoidance

When the implementer tried an approach that did not work — preserved so a future session does not repeat it.

```
**Mistake:** {the approach that was tried}
**Why wrong:** {the constraint or rule it violated}
**Correct location/approach:** {what should be done instead}
```

### Codebase Quirk

A property of the system that future scenarios will encounter. Quirk entries are the primary carryover candidates.

```
**Quirk:** {the unexpected behavior or required setup}
**Where:** {file path or component}
**Implication:** {what callers must do}
```

## DO-WRITE Examples

```
## red-usecase (2026-05-14)

**Expected:** UserNotFoundException with message "User not found"
**Actual:** ValidationException with message "Invalid email format"
**Why:** The request DTO validates email format before the usecase runs, so the lookup branch is unreachable with the test's malformed email.
**Resolution:** Updated the test to use a valid-format email that is absent from storage.
```

```
## design (2026-05-14)

**Decision:** Storage port returns optional for findById, throws a not-found exception for findByIdRequired.
**Why:** Distinguishes expected absence from invariant violation at the port boundary.
**Where applied:** TaskStorage interface in usecase adapters.
```

```
## green-adapter h2 (2026-05-14)

**Surprise:** Column ordering relied on row insertion order in the database adapter, not on the position field that was added in scenario 2.
**Why:** Storage queries used the default ordering and never sorted by the position field.
**Impact:** Any reorder feature must update the position field AND sort by position with insertion-order tiebreak.
```

```
## green-usecase (2026-05-14)

**Mistake:** First attempt placed rate-limit counting in the controller using an in-memory map.
**Why wrong:** Controllers are thin; rate-limit state must be cross-instance, so it belongs in storage.
**Correct location/approach:** RateLimitStorage port, called from the usecase.
```

## DON'T-WRITE Examples

These entries are forbidden — they say nothing a future session cannot derive from progress.md, the commit, the test, or the production code:

```
## green-usecase (2026-05-14)         ← DON'T WRITE
Implemented the usecase per spec. Tests passed.
```

```
## refactor (2026-05-14)              ← DON'T WRITE
Extracted a private helper method. All tests still green.
```

```
## red-acceptance (2026-05-14)        ← DON'T WRITE
Wrote the test, predicted failure, ran it, marked disabled.
```

```
## green-adapter h2 (2026-05-14)      ← DON'T WRITE
Added migration. Repository wired. Tests passed.
```

```
## green-acceptance (2026-05-14)      ← DON'T WRITE
Removed disable marker. Test passes end-to-end.
```

```
## align-design (2026-05-14)          ← DON'T WRITE
Built the component, ran align-design, design-review clean, refactored, coverage clean.
```

The discipline: if the entry would be "I did the step and it worked," write nothing. The next session will read progress.md and see the step is `[x]`. If a prediction matched, do not write — that is the expected case and adds no signal.

## Carryover Format

Carryover uses the same block types but only **Quirk** entries, plus **Decision** entries whose `Where applied` field references code future scenarios will touch. Surprise and Mistake-Avoidance entries stay in the scenario summary unless they describe an enduring system invariant.

Each carryover entry includes a backreference:

```
## {block-type}: {short title}
**...** {block content per the format above}
**From:** scenario {N} ({scenario-slug})
```

Append to `carryover.md` at the story root when the LAST step of a scenario commits. The scenario summary file is not deleted — it stays in `summaries/` as an archive.
