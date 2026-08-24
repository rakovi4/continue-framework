# Platform Monitoring for Finish-Task

Start exactly one context-delivering readiness wake-up for the active invocation.
Do not use a detached timer: the prompt must return to the parent coordinator so it
can inspect task state and dispatch newly ready work.

## Claude Code

Create a native `Monitor` with a five-minute interval and this prompt:

> Reassess the task dependency graph, live agents, newly frozen surfaces, available
> capacity, and whether a newly unblocked disjoint lane would reduce elapsed time.

Use the `Monitor` tool itself. Do not run the repository script, a shell loop, a
background command, a scheduled task, or a cron job. Cancel the Monitor when the
workflow completes, fails, or pauses for a required user decision.

## Codex

Read `../scripts/codex-parallelism-push.js` and submit its exact contents as the body
of `functions.exec`. The file is an orchestration push-script, not a Node.js command.
Retain the cell identifier returned with `Script running with cell ID ...`; do not
poll it with `wait`. On completion, failure, or a required user-decision pause,
terminate that cell with `functions.wait({cell_id, terminate: true})`.

When dispatching agents, use `fork_turns=all` so each worker receives the available
conversation history in addition to the task-specific context packet. If full
history is unavailable, send the maximum supported history and state that limitation
in the coordinator record.
