---
name: design-preview
description: Preview the planned design for a scenario before writing tests. Shows domain model changes, usecase patterns, and key design choices. Use before red-usecase to get user approval on the implementation approach. If the user rejects the design, offers to discuss inline or escalate to /architecture for a full ADR.
---

# /design-preview - Scenario Design Preview

## Usage
```
/design-preview 10 "Filter by date range"    # Story 10, named scenario
/design-preview 10 9                          # Story 10, scenario 9
/design-preview                               # Detect from progress.md
```

## Purpose

Before writing any test code, present the planned implementation design to the user for approval. This catches design disagreements early — before red-usecase locks in the approach.

This is also the reuse gate for a scenario invented mid-cycle (see `.claude/guidelines/workflow-detail.md` "Net-New Scenarios Introduced Mid-Cycle"): a scenario not traceable to a scanned `tests/*` scenario must pass through here so step 2a scans its hazards before its red phase locks.

## Workflow

### 1. Gather Context

1. **Read the story spec** — full story document for business context, requirements, constraints, business rules
2. **Read the scenario** from `tests/01_API_Tests.md`
3. **Read `ProductSpecification/ExpectedLoad.txt`** — for scale assumptions (use real numbers, never guess)
4. **Read existing code** — domain entities, usecases, ports, request/response DTOs
5. **Read ADRs** — check `decisions/*-decision.md` files in the story directory that may constrain the design
6. **Read the acceptance test** (if `red-acceptance` is done) — understand expected API behavior

### 2. Generate Options

Think through 2-3 viable approaches. For each option, capture:
- **Summary** — one line describing the approach (domain changes, ports, sequence)
- **Pros** — 2-3 bullets
- **Cons** — 2-3 bullets

Mark one option as **Recommended** with a one-line rationale ("why this over the others"). For trivial scenarios (validation, error handling, mechanical CRUD) where alternatives would be contrived, present a single option labelled "Only viable approach" instead of forcing artificial alternatives.

### 2a. Hazard Catalogue Scan (before presenting)

Before presenting the options, scan the drafted design against the hazard catalogue —
the spec-time, closed-list complement to the open-ended commit-time review passes. Per
`.claude/guidelines/hazard-catalogue/_index.md` (read its "How to apply it"), fan out one
`hazard-scan-agent` per group in the index's **Groups** list — iterate that list, never a
hand-copied set, or a newly-added group goes unchecked — each carrying the drafted design,
`_index.md`, and its one group file; dispatch them concurrently, collect each pass's GAPs
and seam flags, then run one synthesis pass (per `_index.md`'s "Reason across the seams")
over the index-named seams and every flagged seam. Fold every GAP back into the design
before presenting: the option the user approves must already carry the forced guard (a
domain method, a port contract, a specific check), not a vague mitigation. Do not proceed
to step 3 with an open GAP — a hazard the design can't yet guard is a reason to widen the
options or escalate to `/architecture`, not to present anyway. Groups whose triggers can't
fire at this usecase altitude — the client/frontend group above all — are dismissed as a
block with one explicit "out of altitude here" line (per `_index.md`'s "A dead group is
dismissed as a block"), never silently passed. When you present, surface the scan outcome —
the group set scanned, each fired-trigger GAP, and the guard the chosen option carries for
it — so the user approves a design whose hazards are visible, not hidden.

### 3. Present Options

Show each option as a labelled block: title, summary, pros, cons. Include the recommendation rationale below the recommended option.

**Simple scenarios**: each option in 3-5 lines.
**Complex scenarios**: each option with method signatures/pseudocode, domain model changes, pipeline/sequence diagrams, port changes.

### 4. Get Option Choice

Ask with `AskUserQuestion`:
- First answer = the recommended option, label suffixed with "(Recommended)"
- Other answers = alternative options (one per non-recommended option, up to 3 alternatives)
- Last answer = "Reject all — escalate to `/architecture`"

Option labels must fit in a chip (12 chars). Keep answer descriptions to one short line.

If user rejects all → invoke `/architecture` and STOP. Do not proceed to the ADR question.

### 5. Get ADR Decision

After an option is chosen, ask separately with `AskUserQuestion` whether to capture the decision as an ADR:
- "Write ADR" — recommended when the user picked a non-recommended option, when the trade-offs are non-obvious, or when downstream scenarios will likely revisit the choice
- "Skip ADR" — recommended for trivial scenarios (single-option flow) or mechanical choices with no real trade-off

Pick which option to mark "(Recommended)" based on the choice the user just made in step 4.

### 6. Completion

| Outcome | Action |
|---------|--------|
| Option chosen, no ADR | Mark `design` step as `[x]`. No files created. |
| Option chosen, write ADR | Mark `design` step as `[x]`, then write an ADR using `.claude/templates/spec/adr-format.md` to the story's `decisions/` subfolder. Pre-populate the ADR's "Rejected" table with the un-chosen options from step 3. Commit includes the ADR file. |
| Rejected all → `/architecture` | Do NOT mark `design`. `/architecture` runs and decides the ADR. Mark `design` only after the ADR lands. |

## Rules

- Never write code — this is a design step
- Never create files — design lives in the conversation (unless escalated to `/architecture`)
- Keep it concise — the goal is alignment, not a design document
- If trivially similar to a previous scenario, say so and ask to approve
- **Scope of progress.md changes:** design-preview may ONLY mark the `design` checkbox as `[x]`. It must NOT modify, skip, or rewrite any other steps (usecase, adapter, green-acceptance). Skip recommendations go in the design output text only — `/continue` applies approved skips to progress.md after the design work unit completes, validating each skip against the "zero production files modified" rule in `.claude/guidelines/tdd-rules.md`.
