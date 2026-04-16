---
name: architecture
description: Facilitate architectural decisions during implementation. Use when the developer encounters a design choice with multiple viable approaches (data model, race condition handling, processing strategy, schema design) and needs structured discussion, trade-off analysis, and documentation. Triggers on /architecture or when a conversation reveals competing design options that need evaluation before coding continues.
---

# /architecture - Architectural Decision Record

## Usage
```
/architecture 2 "task ordering within columns"   # Story 2, named decision
/architecture 10                                   # Story 10, discover topic interactively
/architecture                                      # Detect from recent git log
```

## Purpose

When implementation reveals a design fork — multiple viable approaches with different trade-offs — this skill pauses coding to think through the options, document the decision, and plan the implementation with proper TDD steps.

## Workflow

### Phase 1: Context Gathering

1. **Resolve story** from argument (same resolution as `/continue`)
2. **Read** the story spec, current progress, relevant test specs, and existing ADRs
3. **Read** the code involved — domain entities, usecases, adapters, schemas
4. **Summarize** the decision point: what question needs answering, what triggered it, what constraints exist

### Phase 2: Interactive Discussion

1. **Present the problem** — describe the tension or fork point clearly
2. **Propose 2-4 options** with trade-offs (how it works, pros/cons, impact, edge cases)
3. **Use AskUserQuestion** to let the developer choose or propose alternatives
4. **Iterate** until the approach is clear
5. **Draw diagrams** when helpful — write HTML files to visualize complex flows

### Phase 3: Write ADR

Use the format from `.claude/templates/spec/adr-format.md`.

### Phase 4: Update Test Specs

Add edge case scenarios discovered during discussion to the appropriate test spec file.

### Phase 5: Update Progress

Update `progress.md` with TDD steps that implement the decision.

### Phase 6: Commit

Commit message: `Story N: ADR for {decision topic} (Scenario X)`

## Rules

- Never generate code during this skill — it's a planning tool
- Always read existing ADRs in the story's `decisions/` subfolder to avoid contradicting prior decisions
- The developer makes the final call — present options, don't prescribe
- Keep ADRs concise — include current schema/code state when relevant

## Templates

- `.claude/templates/spec/adr-format.md` — ADR document format
