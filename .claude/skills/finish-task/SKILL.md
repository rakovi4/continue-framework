---
name: finish-task
description: Complete all remaining tracked work for any user-created task in one coordinated run, using parallel agents only when they reduce elapsed time. Do not use for stories.
---

# /finish-task - Complete a Task

Carry any tracked task from its current `progress.md` cursor through its final
archive without requiring repeated task-execution commands.

## Workflow

1. Resolve `task N` with `/continue`'s task lookup rules. If already archived, report
   its location; an active task with no open checkbox still owes terminal review.
   Read its type and the workflow that owns that type.
2. Read `.claude/templates/workflow/finish-task-coordination.md` completely and run
   its initial scheduling pass.
3. Read `references/platform-monitoring.md`, then start its single five-minute
   readiness monitor using the exact route for the active platform. Explicitly tell
   the user when the monitor starts, wakes the coordinator, or causes a newly ready
   lane to dispatch.
4. Execute the next work with the template's task-type route. Keep every applicable
   atomic unit, approval, test, review, work-log, and commit boundary; replace only
   the owning workflow's successful intermediate stop with another scheduling pass.
5. Delegate only lanes admitted by the template's dependency, ownership, context,
   and net-speedup gates. The parent remains coordinator and personally validates
   every result.
6. Continue until the task is archived, a required user decision pauses the active
   workflow, or a sub-skill fails. Stop the monitor before the final report or any
   pause.

## Constraints

- Do not turn the task into multiple competing `/continue` sessions.
- Do not parallelize merely because agent capacity exists. Simple, short, dependent,
  or overlapping work stays in the parent.
- Do not overlook frontend/backend concurrency after their shared contract is frozen.
- QA cases are serial; only their design hazards and terminal reviews fan out.
- Give workers full available history and the complete task-specific context packet;
  never delegate from a thin summary.
- Preserve every owning workflow's authorization boundaries and explicit user
  decisions. This skill changes execution duration, not scope or permission.
- Report intermediate lane and work-unit outcomes while continuing, but emit the
  owning workflows' full report fields once, aggregated at the terminal stop.

## Usage

`/finish-task task N`
