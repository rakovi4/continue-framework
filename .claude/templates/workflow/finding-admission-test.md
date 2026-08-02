# The Finding Admission Test

When may a finding become a **plan step**? Read by `.claude/agents/refactor-agent.md`
and `.claude/agents/test-review-agent.md` before reporting anything they did not fix,
and by `/continue` before writing any new checkbox into `progress.md`.

**A checkbox is the most expensive disposal a finding has.** It costs two boxes (a red
and its green), four commits, and two further sub-agent dispatches that are themselves
licensed to find more. Filing is not the neutral option — fixing is. In an unfiltered
review loop, reported findings can add work as quickly as completed steps remove it.

## Stage 1 — Fix it now, and file nothing

If the fix is **behavior-preserving**, apply it in this pass. No checkbox, no report. Behavior-preserving means: no shipped artifact changes what it does for
any input. Renames, dead code and dead references, stale doc anchors, a stale roster, a
comment that outlived its subject, tightening an assertion that already passes.

This holds **regardless of layer, file, or which mandate found it**. A real fix in hand
is always cheaper than a described one. The single exception is a **file-domain lock**
in force for this dispatch — under a lock, report the finding and name the locked file,
because a concurrent writer is mid-edit and the fix would collide.

## Stage 2 — Expansion admission: all five must hold

Only a **behavior-changing** finding may become a step in the current work item, and
only if every one holds:

1. **It names a shipped artifact by path.** A shipped artifact is a file something other
   than the test suite runs or reads at runtime — an executable workflow component, a test runner, an
   agent charter, a skill, a guideline. A test file, fixture, Statements module, or test
   client is **not** a shipped artifact.
2. **It states a concrete failure: input or state → wrong output.** Name both halves.
   "Could drift", "is not exhaustive", "may be tightened later", "is fragile", "nothing
   pins this" are not failures — they are predictions, and this repo's evidence is that
   nobody in this loop predicts severity well.
3. **It was observed, not reasoned.** You ran something and saw it, and you quote what
   you saw; or you name the exact command a reader can run to see it. A finding derived
   only by reading source is not admissible no matter how certain it looks.
4. **The fix changes behavior.** If it does not, Stage 1 already applied and there is
   nothing left to file.
5. **It violates a pre-existing obligation of this work item.** Cite the exact
   requirement, acceptance criterion, repository invariant, or already-landed test
   that existed before the finding. Discovering a desirable new guarantee does not
   retroactively make that guarantee part of the current work item.

Fail any one and the finding does **not expand the current work item**. Classify its
disposition under Stage 3 instead; failure of this gate is not permission to hide it.

## Worked examples

Representative findings run through the test.

| Finding | Verdict |
|---|---|
| A runtime manifest uses a computed description, so the loader refuses it as non-literal in a measured run | **Step only if rule 5 also holds.** Rules 1–4 establish a real behavior change; cite the earlier loading obligation before expanding the work. |
| `run-tests.sh` accepts an empty path argument and exits 0 having run nothing — verified by execution | **Step only if rule 5 also holds.** Cite the earlier test-runner obligation. |
| `fanout-nesting.test.js` still lists a peer that was renamed away | **Stage 1.** Behavior-preserving — fix it in the pass that found it. It never reaches Stage 2. |
| `SCAN_SCHEMA` types its two closed sets as bare `string`; an `enum` derived from `STATUSES` would be tighter | **Record only.** Fails rules 2 and 3: no observed wrong output, only a proposed hardening. Lower-consequence unproven improvement. |
| the deliverable matcher is a regex pinned to today's wording and "goes green the moment the same instruction is rephrased" | **Record only.** Fails rules 1 and 2: test-only prediction, not an observed shipped failure. Lower-consequence unproven improvement. |
| add two fixtures and control rows so every scanner outcome is graded | **Record only.** Fails rule 1: test-only improvement, not a shipped failure. |

The pattern: **a step is something broken now that makes an existing promise of this
work item false.** Other concerns still receive a disposition, but not a checkbox here.

## Stage 3 — Disposition without task inflation

Expansion and importance are separate decisions. A finding that fails Stage 2 still gets
one explicit disposition in the unit report:

| Evidence | Consequence | Disposition |
|---|---|---|
| Proven violation of a pre-existing obligation of this work item | Any | Expand the current work item. |
| Proven serious defect outside that obligation | High | Escalate as a release concern; do not add a checkbox here. |
| Proven unrelated or non-blocking defect | Lower | Preserve as a named follow-up; do not add a checkbox here. |
| Plausible but unproven risk | High | Run one bounded reproduction attempt, then classify the evidence obtained. |
| Plausible but unproven improvement | Lower | Record once in the report; do not add a checkbox. |

The report names the finding, the failed admission rule, its consequence, and its
disposition. A silent rejection is forbidden. A disposition is not permission to create
a shadow backlog: only the user or an existing planning workflow may turn an escalated or
preserved concern into a separate work item.

## Consumer obligations

`/continue` enforces the form it was handed rather than trusting the reporter:

- A reported finding that **does not carry all five** cannot expand the current work item.
  Do not upgrade it by rewriting its wording; assign its Stage 3 disposition.
- **The orchestrator is bound by this test too.** A step written while planning, gating,
  or sequencing is a checkbox like any other and must pass Stage 2.
- A step admitted under this test **cites the observation** in its own annotation, so a
  later reader can re-run it rather than re-argue it.
- Every non-admission is **named in the report** with the rule it failed, its consequence,
  and its disposition.

## What this deliberately excludes

A test that passes for the wrong reason fails rule 1, and in this repo the test suite is
substantially the product. That exclusion is **intended and it has a known cost**: vacuity
in the suite does not expand the current work item unless it proves an existing obligation
false. It still receives a Stage 3 disposition.

The trade is accepted because an unfiltered loop can file steps at the rate it closes
them. The failures that merit expansion are the ones a reproduction exposes against an
obligation the work already had, not guarantees invented during review.
