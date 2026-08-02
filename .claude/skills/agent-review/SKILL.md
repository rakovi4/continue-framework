---
name: agent-review
description: Review the latest work unit with fresh, unnarrowed eyes and surface any problem it contains as follow-ups. Use after a work-unit commit, or when the user runs /agent-review.
---

# /agent-review — Fresh Eyes on Finished Work

A fresh-context pass that reads the latest work cold and surfaces any problem the
work contains. Distinct from `/premortem`: that imagines what the work is
*missing*; this audits what it *holds*. The two are complementary lenses, not a
repeated read.

## Usage

- `/agent-review` — review the latest work-unit commit (`HEAD`)
- `/agent-review <ref>` — review a specific commit or range

## Workflow

1. Load `.claude/agents/agent-review-agent.md`.
2. Resolve the diff: default to the last commit (`HEAD`); use `<ref>` if given.
3. Dispatch named agent `agent-review-agent` with the diff and one line of context
   on what the work unit did, and await its result before continuing. This skill
   must never return PASS before the review has actually run.
4. Surface the agent's verdict: PASS is silent; CONCERNS/BLOCK list each problem,
   its place in the diff, and the named missing guard, as follow-ups. Findings
   never revert the commit.

## Dispatch context

When an orchestrator (`/continue`) dispatches this as a boundary review pass, the
agent runs **concurrently** with `premortem` — two independent fresh-context reads
of the same diff. The timing and the diff it reads in that path (every commit of the
just-completed scenario or task step, dispatched in that boundary unit's `/refactor`
batch — it does not run on mid-block units) are owned by `/continue`; see its
"Boundary Review Passes" section. A deterministic triage predicate runs *before*
that dispatch and may skip both passes for an inert boundary. When they do run,
`/continue` reads each finding's fixability tag and consumes the SAFE subset in an
inline auto-fix (a separate `review-fix:` commit), while a NEEDS_CLARIFICATION
finding — the last resort, gated by
`.claude/templates/workflow/clarification-escalation-test.md` — is resolved by a
single batched boundary quiz; see its "Triage & Auto-Fix" section. Run standalone, this skill reviews `HEAD` (or
`<ref>`) on demand. The agent is read-only; it reports, it does not edit.
