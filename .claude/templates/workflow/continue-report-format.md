# Continue Report Format — Re-Orientation Block

The last thing a `/continue` invocation prints, above its one-line `/plain` hint. This
file is the authority for the block's shape; `/continue`'s "Stop and Report" section
owns everything above it.

Why it exists: an engineer runs several `/continue` sessions in parallel terminals and
comes back to one of them cold, minutes or hours later. Nothing in the technical report
answers "which of my four terminals is this, and where in that work item am I?" without
being read end to end. The block answers it in six lines.

## Placement

Emit it **after** the test results, review-pass verdicts, red-prediction sections, and
next-step line — and **immediately before** the `/plain` hint. A terminal scrolls: the
last thing written is the only thing still on screen when the engineer returns, so the
re-orientation must sit at the bottom. Anything appended after it steals that position.

Emit it on **both** valid stop points, not only the successful one — after the work
unit's last commit, and when a sub-skill failed and dispatch stopped. A failed unit is
when orientation is worth most; see "When the work unit failed" below.

## Shape

Fixed labels, fixed order, one line each, values aligned in a column. Same six lines
every invocation — the shape is what makes it scannable at a glance rather than read.

```
**Where you are**
Work item: Story NN — {Feature}
Scenario:  Tier 1 — Backend · 1.3 {Scenario title}
Done:      green-usecase
Next:      adapters-discovery
Position:  step 4/6 in this scenario · 2/9 scenarios in Tier 1
Summary:   The application can now decide whether a submitted {Entity}
           is acceptable, and that decision is covered by tests. It is
           not stored anywhere yet.
```

Task example — same labels, except the block line is `Step:` because a task has step
sections, not scenarios:

```
**Where you are**
Work item: Task 4 (refactoring) — {short task title}
Step:      Step 2: {step description}
Done:      green-adapter storage
Next:      refactor (cleanup)
Position:  step 2/3 in this step · 6/9 checkboxes in the task
Summary:   Reading and writing {Entity} records now goes through the
           renamed module, and the old path is gone. Behavior is
           unchanged — this was a move, not a feature.
```

## Field derivation

| Field | Story | Task |
|-------|-------|------|
| `Work item` | `Story NN — {Name}`: number and name from the row in `ProductSpecification/stories.md` that step 10 just updated, cross-checked against the `progress.md` H1 (`# Story N: Story Title — Progress`) | `Task N ({type}) — {Title}`: number and title from the `progress.md` H1, type from its `Type:` line |
| `Scenario` / `Step` | The `### {N}.{M} {Title}` heading of the block the completed step sits in, **verbatim** — never renumbered or re-worded. Prefix with tier and category from the enclosing `## Tier N — {Category} Scenarios ({file})` heading, joined by ` · ` | The enclosing `### Step N: …` heading, or the `## Fix: …` heading for a bugfix task, verbatim |
| `Done` | The checkbox this invocation flipped to `[x]` or `[S]`, by its progress.md label | same |
| `Next` | The step the invocation advanced to — the first `[~]`/`[ ]` after the update, selected exactly as step 4 selects it | same |
| `Position` | `step {k}/{n} in this scenario` over the block's checkboxes, then ` · ` and the scenario fraction for the current tier from the `Tests` value just written to `stories.md` | `step {k}/{n} in this step` (or `in this fix` for a bugfix task), then ` · {done}/{total} checkboxes in the task` |
| `Summary` | See below | same |

The number is never a bare `NN` on its own line: four terminals each showing a number
tell the engineer nothing. Number and name always travel together.

**Unavailable values.** Print the fallback, never an invented value and never a dropped
line — a missing line breaks the fixed shape that makes the block scannable.

- No row in `stories.md` for the story → use the `progress.md` H1 name and append
  ` (no stories.md row)`. Do not go looking for a name elsewhere.
- Completed step sits under `## Spec` or `## Harvest — Tier 1 → Tier 2`, which carry no
  `### ` heading → print the section heading as the `Scenario:` value; the `Position`
  block fraction counts that section's checkboxes.
- No `[~]`/`[ ]` remains → `Next: none — work item complete`, and for a work item that
  moved to `done/` — a task or a story — append ` (moved to done/)`.
- A tier or category cannot be read because the plan is untiered → omit the prefix and
  print the scenario heading alone. An untiered plan is not a fault; nothing is missing.

## The Summary field

Two sentences at most, in plain language, written for someone who has not read a line of
the report above it. It says what the work unit actually achieved in terms of what the
product can now do, or what changed structurally — not what was executed.

Keep out of it: agent names, step names, file paths, module or class names, commit
shas, test counts, verdicts, and any term that only means something mid-cycle
(`red`, `green`, `harvest`, `port`, `adapter`). Those are all either in the report above
or in the block's other fields.

```
Summary:   The application can now reject a duplicate {Entity} before      ← GOOD
           it reaches storage. Nothing calls this from the outside yet.

Summary:   green-usecase landed; red-agent's prediction matched; 14        ← BAD
           passed, 0 failed; refactor-agent extracted a helper.
```

The bad one is the report restated in its own vocabulary. It re-orients nobody, because
understanding it requires the context the engineer came back to recover.

## No duplication

The block restates **identity and position only**. It must not re-print test pass/fail
counts, the `agent-review` / `premortem` verdicts, the `review-fix:` findings, or the
red-phase **Predicted failure** / **Actual failure** / **Comparison** sections. Each of
those has a mandated form higher in the report (`/continue`'s "Stop and Report", and
`.claude/templates/workflow/red-phase-formats.md`); a second, looser rendering of the
same facts at the bottom invites the two to disagree, and a report that contradicts
itself is worse than one that is merely long.

Repeating the *next step* and the *progress fraction* is intended, not duplication —
they are the position the block exists to carry, and the engineer must not have to
scroll up for them.

## When the work unit failed

A stop on sub-skill failure prints the same six lines, with two differences: `Done:`
names the step that did **not** complete, suffixed ` (failed — not marked)`, and the
summary says plainly what stopped and what it was blocked on, in the same plain
vocabulary. `Next:` stays the failed step — it is still the next work unit. The block
never claims progress the plan does not record.
