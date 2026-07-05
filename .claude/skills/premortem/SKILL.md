---
name: premortem
description: Imagine the incident a just-shipped work unit would cause and surface unguarded gaps as follow-ups. Use after a work-unit commit, or when the user runs /premortem.
---

# /premortem — Imagine the Incident

A fresh-context pass that assumes the latest work shipped and caused an incident,
then works backward to the gap. Distinct from `/agent-review`: that audits what
the work contains; this imagines what it is missing. The two are complementary
lenses, not a repeated read.

## Usage

- `/premortem` — review the latest work-unit commit (`HEAD`)
- `/premortem <ref>` — review a specific commit or range

## Workflow

1. Load `.claude/agents/premortem-agent.md`.
2. Resolve the diff: default to the last commit (`HEAD`); use `<ref>` if given.
3. Dispatch `premortem-agent` (Agent tool) with the diff and one line of context
   on what the work unit did.
4. Surface the agent's verdict: PASS is silent; CONCERNS/BLOCK list each imagined
   incident, its mechanism in the diff, and the named missing guard, as
   follow-ups. Findings never revert the commit.

## Dispatch context

When an orchestrator (`/continue`) dispatches this as a work-unit review pass, the
agent runs **concurrently** with `agent-review` — two independent fresh-context
reads of the same diff. The timing and the diff it reads in that path (the pre-refactor
behavior commit — `HEAD` or `HEAD~N..HEAD` — dispatched in the `/refactor` batch)
are owned by `/continue`; see its
"Pre-Commit Review Passes" section. Run standalone, this skill reviews `HEAD` (or
`<ref>`) on demand. The agent is read-only; it reports, it does not edit.
