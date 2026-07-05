---
name: handoff
description: Write a journey summary capturing noteworthy moments (predictions, decisions, surprises, mistakes, quirks). Runs automatically the moment the agent observes something worth noting during work, and manually before /clear or /compact as a final sweep. Idempotent — skips entries already recorded. Use when the agent observes a noteworthy moment, before clearing context, or when the user mentions /handoff.
---

# /handoff - Preserve Conversation Context

Run this to persist what a future session would otherwise lose. `/handoff` runs automatically the moment the agent observes something worth noting during work, and manually before `/clear` or `/compact` as a final sweep. `/handoff` is the ONLY writer of journey summaries and carryover.

## Workflow

1. **Identify the work item** -- find the story or task the conversation worked on (recent git log `Story N` / `Task N`, or the `progress.md` that changed). Resolve its folder.
2. **Locate the last work-unit commit** -- the conversation since that commit is the review window. Everything after it (discussion, debugging, decisions) is what `/handoff` captures; the work unit itself is already recorded in `progress.md` and its commit.
3. **Review the window** against the "When to Write" triggers in `.claude/templates/workflow/summary-format.md`. Decide, per trigger, whether anything noteworthy happened.
4. **Write entries, or nothing** -- if at least one trigger fired, append entries to the summary file (see File Layout) in the strict format from `.claude/templates/workflow/summary-format.md`. Before appending, check the file for an entry already covering the same moment and skip it -- `/handoff` runs many times per conversation and must not duplicate. If nothing fired, or every fired trigger is already recorded, create no file and append no line -- report "nothing to record".
5. **Promote carryover** -- if a scenario's last step is now `[x]` (scenario complete), promote codebase-quirk and system-invariant entries from that scenario's summary to `carryover.md` at the story root, each with a `From: scenario N (slug)` backreference. Tasks have no carryover.
6. **Report** -- list each file touched and each entry appended (or "nothing to record"), then tell the user it is safe to `/clear`.

## File Layout

| Work item | Summary file | Carryover |
|-----------|--------------|-----------|
| Story scenario | `ProductSpecification/stories/NN-story-name/summaries/{scenario-slug}.md` | `ProductSpecification/stories/NN-story-name/carryover.md` |
| Task | `ProductSpecification/tasks/N-type-slug/summary.md` | none |

`{scenario-slug}` derives from the scenario heading in `progress.md`. Files are created lazily -- only on first append.

## Constraints

The append-only, lazy-creation, idempotent, strict-format, and no-forward-looking-instructions rules are defined in `.claude/templates/workflow/summary-format.md` and `.claude/guidelines/workflow-detail.md` (Resuming Across Conversations). Apply them — do not restate them. `/handoff` is the sole writer of journey summaries and carryover; `/continue` only reads them.

## Authoritative References

- `.claude/guidelines/workflow-detail.md` -- "Resuming Across Conversations": how journey summaries fit the workflow, who writes and reads them.
- `.claude/templates/workflow/summary-format.md` -- when to write, entry header, block types, length limit, DO/DON'T-WRITE examples.
