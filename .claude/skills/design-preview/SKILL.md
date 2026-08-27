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

### Concurrent Contract-Design Mode

When Stage 1 of `parallel-backend-stages.md` dispatches this skill beside acceptance
RED, do not ask questions or wait for the acceptance lane. Infer the design from the
scenario, existing architecture, and acceptance criterion; discover every adapter;
create the use-case, port, and adapter skeletons; and commit only the declared files.
Record a material choice in an ADR when needed. The coordinator presents the test
and frozen interfaces together for user review after both lanes join.

The acceptance test is optional input in this mode: inspect its committed form when
available, but never make either lane depend on the other's completion.

Before returning, apply `parallel-backend-stages.md`'s Stage 2 lane-plan gate. Keep
all collaborating classes and focused tests for one use case or adapter boundary in
one complete lane; never split by production class, test class, guard subset, or work
size. Thus a scenario owned by one adapter produces one RED agent for its complete
focused test surface followed by one GREEN agent for its complete production fix.
The frozen-surface and writable-path inventories are not test inventories. Name each
lane's architectural test boundary and its public entries: usecase methods or the
adapter's technology-facing entries/implemented ports. Internal requests, responses, DTOs,
mappings, persistence models, security helpers, resolvers, and exception translators
are collaborators covered through that entry, never standalone test targets.
Freeze natural seams so genuinely independent lanes can start together, and do not
mistake cross-lane post-join verification for an implementation dependency; focused
composition inside one adapter stays in that adapter's RED surface. Return each
lane's architectural unit, each writable path with its intended behavior delta,
and separately named frozen symbol/signature/model surfaces. Never return a dependency
between Stage 2 lanes: freeze the seam, coalesce the work, or fail the design gate.
The coordinator records the independent-lane plan for approval and Stage 2 dispatch.

### Concurrent Frontend Interface-Design Mode

When Stage 1 of `parallel-frontend-stages.md` dispatches this skill beside Selenium
RED, do not ask questions or wait for the Selenium lane. Infer the design from the
scenario, mockup, existing frontend, and acceptance criterion. Declare the shared
component, logic, API-client, type, and test interfaces needed by Stage 2, then
create only those interface surfaces within the coordinator's file manifest.

Do not implement lane behavior, stage, commit, or edit `progress.md`. The Selenium
test is optional input: inspect it when available, but neither lane depends on the
other. Return the declared interfaces, changed paths, and checks to the coordinator,
which freezes them after the Stage 1 join.

### 1. Gather Context

1. **Read the story spec** — full story document for business context, requirements, constraints, business rules
2. **Read the scenario** from the category file named by its progress section:
   `01_API`, `06_Integration`, `05_Security`, `03_Load`, or `04_Infrastructure`
3. **Read `ProductSpecification/ExpectedLoad.md`** — for scale assumptions (use real numbers, never guess)
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
the spec-time, closed-list complement to the open-ended commit-time review passes.
Dispatch it exactly as `.claude/guidelines/hazard-catalogue/_index.md` prescribes (read
its "How to apply it", "The dispatch shape"); the artifact under scan is the **drafted
design**. At this altitude an entire group's triggers often cannot fire — `hz-08` (client
/ frontend) above all — which is a block dismissal, never a silent pass (`_index.md`, "A
dead group is dismissed as a block").

Fold every GAP back into the design before presenting: the option the user approves must
already carry the forced guard (a domain method, a port contract, a specific check), not a
vague mitigation. Do not proceed to step 3 with an open GAP — a hazard the design can't
yet guard is a reason to widen the options or escalate to `/architecture`, not to present
anyway. When you present, surface the scan outcome — the group set scanned, each
fired-trigger GAP, and the guard the chosen option carries for it — so the user approves a
design whose hazards are visible, not hidden.

When a GAP folds in as a **net-new scenario** rather than as a change to the design,
classify it immediately using `.claude/templates/spec/tier-ladder.md`. It can never be
Tier 1. Write a qualifying Tier 2 scenario under `tests/`; otherwise write its Tier 3
marker under the matching `tests/tier3/` category file and do not add it to
`progress.md`. Preserve the scan's group id; this is the only point on the mid-cycle
path where that provenance is known.

A scenario that reaches this gate from a `NEEDS_CYCLE` review finding rather than from a
GAP uses the review-finding tier policy, carrying whatever tokens this scan stamped and
no invented token when it stamped none. A review pass is not a provenance route.

Resolved, not `Tier: ?`. The `?` form means "drafted, awaiting the comparative pass", and
`tiering-agent` runs at spec time only — a `?` written here would sit unresolved on an
already-tiered story and read to the next person as a pass that got skipped. A
hazard-generated scenario uses the strict Tier 2-or-3 decision above and never Tier 1.

**Consolidation does not reach back.** The pass that merges scenarios sharing one
execution runs once, at `/test-spec`, over the whole drafted set
(`.claude/templates/spec/consolidation-rules.md`). A scenario born here arrives after it
and is **never retro-merged**: re-running a whole-set pass to absorb one newcomer would
rewrite scenarios already built or in flight, and their `### N.M Title` headings are what
`progress.md`, the journey summaries and plan-integrity check 4 key on. So the two
outcomes above stay the only ones — fold the GAP into the design, write a qualifying
Tier 2 scenario that costs a full cycle, or record a Tier 3 scenario that costs none.
Fold wherever folding is honest; never call a distinct observable behavior a design change.

### 3. Present Options

Show each option as a labelled block: title, summary, pros, cons. Include the recommendation rationale below the recommended option.

**Simple scenarios**: each option in 3-5 lines.
**Complex scenarios**: each option with method signatures/pseudocode, domain model changes, pipeline/sequence diagrams, port changes.

### 4. Get Option Choice

Request a user decision using structured input when available, otherwise ask
directly and pause:
- First answer = the recommended option, label suffixed with "(Recommended)"
- Other answers = alternative options (one per non-recommended option, up to 3 alternatives)
- Last answer = "Reject all — escalate to `/architecture`"

Option labels must fit in a chip (12 chars). Keep answer descriptions to one short line.

If user rejects all → invoke `/architecture` and STOP. Do not proceed to the ADR question.

### 5. Get ADR Decision

After an option is chosen, request a separate user decision on whether to capture
the decision as an ADR, using structured input when available and otherwise
asking directly:
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

- Never write code in ordinary preview mode. Concurrent contract-design and
  frontend interface-design modes are explicit exceptions: create only their
  declared skeleton or interface files.
- Never create files in ordinary preview mode. Exceptions are concurrent
  contract-design mode, an escalation to `/architecture`, and step 2a's write of a
  net-new mid-cycle scenario into its category file.
- Keep it concise — the goal is alignment, not a design document
- If trivially similar to a previous scenario, say so and ask to approve
- **Scope of progress.md changes:** design-preview never edits `progress.md` in
  either concurrent mode; the coordinator owns it. In ordinary mode it may only
  mark `design` `[x]` and must not rewrite other steps.
