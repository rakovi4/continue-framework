# Work Log Format

`worklog/` lives at the story or task root beside `progress.md`. `/continue` creates
it lazily and writes one Markdown record per invocation instead of attaching
narrative to progress checkboxes. Each record is committed with the work unit and
must stay within the repository's 200-line file limit.

## Separation of concerns

- `progress.md` answers only: what is the plan, what is done, and what runs next?
- `worklog/` records what happened while a work unit ran: outcomes, test counts,
  red predictions, review verdicts, approval/rejection context, lane manifests and
  checkpoints, discovery evidence, skip reasons, and cycle proposals.
- `summaries/` and `carryover.md` preserve noteworthy cross-conversation context.
  `/handoff` remains their sole writer; routine work-log entries never replace them.
- Decision records remain the authority for architectural choices. A work-log entry
  may link to one but must not duplicate it.

## Record naming and shape

Name a record `{YYYYMMDDTHHMMSSZ}-{step-slug}.md`; add a numeric suffix only on
collision. Use the exact enclosing progress heading and checkbox label inside it.
One invocation may update its record while a composite stage is in flight; after
completion it is immutable. If it would exceed 200 lines, continue in `-part-N.md`
files and link each part to the next.

```markdown
# 1.2 Scenario title — stage-2 implementation lanes

Started: 2026-01-14T10:35:00Z

Outcome: completed

- Change: implemented the approved use-case and storage lanes.
- Tests: usecase 12 passed, 0 failed; storage 18 passed, 0 failed.
- Commits: usecase `abc123`; storage `def456`.

<!-- stage-2-plan:
usecase: unit={boundary}; writes=[{path}: {delta}]; frozen-surfaces=[...]
storage: unit={boundary}; writes=[{path}: {delta}]; frozen-surfaces=[...]
-->
<!-- lanes: usecase=abc123 PASS; storage=def456 PASS -->
```

Use only the fields the work unit produced. `Outcome` is required (`in-progress` or
`completed`); prose bullets and
machine-readable HTML comments are optional. Keep resumable coordinator state in
the active entry, including partial lane publication and joined-review checkpoints.

## Progress references

Most checkboxes need no reference: the latest matching record is discoverable by its
heading and label. A later decision step that must consume a particular record uses
a compact relative pointer such as `(worklog: 20260114T103500Z-stage-3.md)`; the
record itself stays in `worklog/`.
Parser-required compact tokens such as component ids, discovery counts, and
`plan: +N/-N/~N` may remain on the checkbox line.

## Failure handling

A failed sub-skill does not advance or commit `progress.md`. Report the failure to
the user. Add it under `worklog/` only if the workflow already requires a durable
checkpoint commit for resumability; otherwise the next invocation reconstructs
state from committed code, tests, and prior records.
