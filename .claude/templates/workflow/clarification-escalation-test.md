# The Clarification Escalation Test

When may a boundary review pass hand its fix direction to the user instead of
deciding it? Read by `.claude/agents/agent-review-agent.md` and
`.claude/agents/premortem-agent.md` before tagging a finding `NEEDS_CLARIFICATION`,
and by `/continue` before quizzing one.

**Escalation is the last resort, not the neutral option.** A quiz stops a work unit
and spends the user's attention on reading a question written in the diff's
vocabulary rather than the product's. That cost is worth paying only when the answer
genuinely is not the reviewer's to give. Deciding the fix direction is part of the
review, not a liberty the reviewer is taking.

## All three must hold

1. **Not derivable.** The answer is not settled by a rule file, a guideline, the
   story spec, an existing convention, or an invariant another file already states.
   If it is, read that and decide — a repo-derivable answer is never a user's to
   give.
2. **No better option.** The candidates are genuinely equal on cost, blast radius,
   and reversibility. If one is defensibly better, picking it is the reviewer's call.
   "I would rather the user owned this" is not a tie.
3. **Statable in one plain sentence.** The question can be posed in a single sentence
   naming the concrete consequence in the product's own terms, without the reader
   holding the diff in their head. If it cannot, the reviewer has not finished
   reasoning about the finding — that is a signal to keep working, never to hand it
   over.

Fail any one of them and the finding is resolved by the reviewer: pick the better
direction, tag it `SAFE` or `NEEDS_CYCLE`, and **state the decision with its one
reason** so the choice is auditable in the report.

## What passing looks like

Two independent passes converging on the same contradiction is evidence it is **real
and decidable** — not evidence it needs a user. What actually passes is narrow: the
fix turns on product intent, a business rule, or a priority the repo records nowhere.

A finding that passes carries its options with the **recommended one first and its
reason**, so the answer can be a single keystroke.

## Consumer obligations

`/continue` enforces the form it was handed rather than trusting the tag:

- A `NEEDS_CLARIFICATION` finding **with no recommended option** is incomplete —
  demote it to `NEEDS_CYCLE` and surface it as a follow-up. Do not ask.
- A question that **cannot be restated in one plain sentence** in the product's terms
  gets the same treatment. The reviewer owed that sentence; a quiz is not the place
  to discover it is missing.
- **One quiz per boundary**, batching every surviving finding — never one call per
  finding. The passes run once per completed story block or whole task, so this is also one
  quiz per scenario, not one per work unit.
- If the user **declines or skips** the quiz, take each finding's recommended option,
  route it, and say so in the report. A declined quiz is an answer: *you decide*.
