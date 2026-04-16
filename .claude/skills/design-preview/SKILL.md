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

## Workflow

### 1. Gather Context

1. **Read the story spec** — full story document for business context, requirements, constraints, business rules
2. **Read the scenario** from `tests/01_API_Tests.md`
3. **Read `ProductSpecification/ExpectedLoad.txt`** — for scale assumptions (use real numbers, never guess)
4. **Read existing code** — domain entities, usecases, ports, request/response DTOs
5. **Read ADRs** — check `decisions/*-decision.md` files in the story directory that may constrain the design
6. **Read the acceptance test** (if `red-acceptance` is done) — understand expected API behavior

### 2. Analyze and Design

Think through: domain changes needed, ports needed, multiple viable approaches and recommendation.

### 3. Present the Design

**Simple scenarios** (validation, error handling, single CRUD): brief text summary (3-5 lines).

**Complex scenarios** (new domain concepts, filtering, multi-step workflows): text summary plus method signatures/pseudocode, domain model changes, pipeline/sequence diagrams, port changes.

### 4. Get Approval

Ask with `AskUserQuestion`: Approve / Approve and ADR / Needs changes / Reject — need `/architecture`.

### 5. Completion

- **Approve**: mark `design` step as `[x]`. No files created.
- **Approve and ADR**: mark `design` step as `[x]`, then write an ADR using `.claude/templates/spec/adr-format.md` to the story's `decisions/` subfolder. Commit includes the ADR file.
- **Reject → `/architecture`**: mark after ADR is decided.

## Rules

- Never write code — this is a design step
- Never create files — design lives in the conversation (unless escalated to `/architecture`)
- Keep it concise — the goal is alignment, not a design document
- If trivially similar to a previous scenario, say so and ask to approve
- **Scope of progress.md changes:** design-preview may ONLY mark the `design` checkbox as `[x]`. It must NOT modify, skip, or rewrite any other steps (usecase, adapter, green-acceptance). Skip recommendations go in the design output text only — `/continue` applies approved skips to progress.md after the design work unit completes, validating each skip against the "zero production files modified" rule in tdd-rules.md.
