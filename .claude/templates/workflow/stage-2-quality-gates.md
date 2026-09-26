# Stage 2 Quality Gates

Both backend and frontend stage coordinators load this contract before dispatch.
Materialize each lane's phases using `story-quality-checklist.md` before its writers
start. Update those checkboxes after each completed skill result; the evidence
below is mandatory for the matching entry, including after resume or recovery.
The coordinator dispatches `/test-review`, `/test-coverage`, and `/refactor` as
separate required phases using `/continue`'s sub-skill routing. A GREEN worker
return is an implementation candidate, not a completed lane. Workers must not
decide whether these phases are useful or run nested detector fan-outs.

## Scope and sequence

1. Compare each lane's final changed paths with its declared baseline and manifest.
   Account for every touched module, production file, test case, and test helper.
   Include domain collaborators, application wiring, every adapter, frontend logic,
   API clients, components, and styles. Shared helpers have one explicit owner.
   A lane may batch its targets, but may not sample files or omit a module or test.
   Related files outside the manifest are read-only context; the coordinator must
   reconcile ownership before assigning fixes there. Shared test review/refactor
   evidence may be reused only when it covers the same targets and revisions.
2. After RED, run `/test-review` over every new or changed test and its helpers.
   Commit the reviewed RED tests, then run `/refactor` over that test surface and
   publish its changes separately before enabling the tests. Preserve RED
   assertions and recorded raw failure evidence. Test review may overlap GREEN
   production work on disjoint paths; refactoring starts only after writers of its
   target paths have returned.
3. After GREEN, run `/test-coverage` for every touched production module using
   explicit lane paths and the recorded baseline, including committed changes.
   Measure frontend as well as backend code. Classify gaps and complete admitted
   follow-ups under the existing finding-admission rules. A missing report or empty
   focus caused by a bad filter cannot pass. For non-executable files, record why
   no coverage metric applies; they still belong to the refactor scope.
4. Commit the verified behavior, then invoke `/refactor` over the lane's complete
   production and test scope. Stage 1 skeleton scans and a worker's informal review
   cannot satisfy this phase. Await the full checklist scan and any fixes; run
   affected checks and publish refactoring in a separate commit. `NO_CHANGE` is
   valid only as the result of that completed skill execution.
5. For design alignment, the coordinator dispatches component build, alignment,
   design review, test review of the tests exercising the component, coverage,
   behavior commit, refactor, and verify-only alignment. Changed test behavior
   follows RED discipline. Existing tests may be reviewed without inventing new
   ones; absent test coverage is assessed by the coverage phase, never silently
   treated as a successful test review.

## Completion evidence

Keep one checkpoint per lane in the invocation work log, with these named results:

| Result | Required evidence |
|--------|-------------------|
| Scope | Baseline, owned paths grouped by module, and checked file revisions |
| Test review | Reviewed test targets and helpers, completed skill result, and joined verification |
| RED refactor | Scanned test paths, completed skill result, commit or evidenced `NO_CHANGE` |
| Coverage | Measured production paths per module, report location and counts, gap dispositions |
| GREEN refactor | Scanned production and test paths, completed skill result, commit or evidenced `NO_CHANGE` |
| Refactor applicability and exemptions | Role inventory, every applicable M/D/T check, and per-candidate KEEP evidence under `restraint.md`; no language/extension-based waiver of shared principles |
| Structure and formatting | B13 capability grouping evidence; A60 formatter/manual check; A0 final physical line counts after formatting, for both RED and GREEN scopes |
| Final verification | Affected suite results and final checked revisions; verify-only alignment for design lanes |

Design lanes without a RED phase record that fact; their post-behavior refactor
still covers all owned code and tests, with linked evidence for shared tests. A
test-review scan that finds no test targets records the empty scope explicitly
alongside the coverage assessment.
Neither fact excuses skipping the remaining phases.

Before marking a lane or Stage 2 complete, reconcile the changed-path inventory
against these results and the required quality entries. Missing, pending, skipped,
or unsupported entries block completion. Bare `PASS`, passing tests, coverage
percentages alone, or an unsupported `NO_CHANGE` do not establish completion. Run missing phases before
advancing to Stage 3; do not ask whether to run them.
Validate B13 against the directory boundary check in `scan-design.md`: require
the file inventory and MOVE/KEEP verdicts, with every MOVE resolved in the final
paths. A summary such as "no further split" cannot replace that evidence. Missing
evidence, unsupported exemptions, syntax-only skips, or unformatted source block completion even when raw line counts meet
the limit. Reconcile file moves with lane ownership and update imports, discovery,
and test paths before rerunning affected checks.

Apply the same gates to coverage follow-ups and reopened lanes. Validate recorded
phase revisions using `story-quality-checklist.md`; later unverified edits
invalidate results for affected paths: repeat test review for changed test behavior,
refresh affected coverage measurements, and refactor changed code and tests before
final verification. On resume, reuse evidence only for matching checked revisions.
