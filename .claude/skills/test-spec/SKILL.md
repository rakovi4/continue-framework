---
name: test-spec
description: Generate BDD test specifications for story in 6 categories (API, UI, Load, Infrastructure, Security, Integration). Use when user wants to create test cases or mentions /test-spec command.
---

# Generate Test Specifications

Generate BDD-style test specifications for a story in 6 categories. Each category produces two files: **main** (critical tests) and **extended** (nice-to-have tests).

## Usage
```
/test-spec "Story name"
/test-spec 5              # By MVP story number
/test-spec                # Interactive selection
```

## Workflow

### Phase 1: Context & Story Selection

Read before generating: `ProductSpecification/BriefProductDescription.md`, `ProductSpecification/stories.md`, `ProductSpecification/ExpectedLoad.md`, story folder (`stories/*/`): mockups, `*.md`, `endpoints.md`, `interview.md`.

Parse input: by name (`"Login/Logout"`), by number (`5`), or interactive (list and ask).

If `interview.md` exists, extract:
- Business rules and constraints → map to API test scenarios
- Explicit edge cases (column transitions, task ordering, concurrent edits) → map to extended tests
- External API error modes → map to integration tests
- Rate limits and performance constraints → map to load tests when they exercise the project's declared **Load Challenge Profile** (read `ExpectedLoad.md` to identify it); skip constraints that don't match the project's profile

**Prerequisite analysis** (mandatory): Read the story's Prerequisites section and Validation Rules table. For each prerequisite (Board exists, Column exists, etc.), generate guard scenarios in BOTH API and UI tests following the Prerequisite Guard Checklist in `test-spec-format.md`. Cross-reference existing stories (e.g., Story 5 `tests/01_API_Tests.md` sections 0-1, `tests/02_UI_Tests.md` section 0) for established blocker patterns.

**Side-effect & idempotency analysis** (mandatory): Scan the story spec and `interview.md` for operations that move money, call an external system, send email, or mutate persisted state in a batch. For each one that can be re-run (scheduled job, webhook, user retry), generate re-run-safety scenarios in BOTH directions — inbound duplicate-event and outbound re-attempt-after-partial-failure — following the Side-Effect & Idempotency Guard Checklist in `test-spec-format.md`. These are critical-path, never extended.

### Phase 2: Generate Test Files

Load `.claude/templates/spec/test-spec-format.md` for category formats, ordering principles, and BDD rules.

Create files in `ProductSpecification/stories/NN-story-name/tests/`:

**Main files (critical tests — typically ~27-34 total, but this describes expected output, not a budget: never drop a guard scenario derived above to hit a count):**
- `01_API_Tests.md`, `02_UI_Tests.md`, `03_Load_Tests.md`
- `04_Infrastructure_Tests.md`, `05_Security_Tests.md`, `06_Integration_Tests.md`

**Extended files in `extended/` subfolder (nice-to-have edge cases):**
- `extended/01_API_Tests_Extended.md` through `extended/06_Integration_Tests_Extended.md`

Add this header to extended files:
```markdown
> These are additional edge case tests. Implement after core tests pass.
```

### Phase 3: Hazard Catalogue Scan

After the test files are drafted, scan them against the hazard catalogue — the spec-time,
closed-list complement to the open-ended commit-time review passes, and the
generalization of the Phase 1 side-effect/idempotency analysis to every hazard class. Per
`.claude/guidelines/hazard-catalogue/_index.md` (read its "How to apply it"), fan out one
`hazard-scan-agent` per group in the index's **Groups** list — iterate that list, never a
hand-copied set, or a newly-added group goes unchecked — each carrying the drafted test
files, `_index.md`, and its one group file; dispatch them concurrently, collect each
pass's GAPs and seam flags, then run one synthesis pass (per `_index.md`'s "Reason across
the seams") over the index-named seams and every flagged seam. Fold every GAP back as the
missing forced-guard scenario — a test that goes red on the hazard — into the matching
category file, critical-path, never extended. A gap closes only when a named scenario
would fail on the bad behaviour. An unresolved GAP blocks Phase 4: fold every fired-trigger
GAP into a scenario, or explicitly dismiss it with a reason, first.

### Phase 4: Summary

Report: folder path, files created, test counts per file, and the hazard-scan result —
the group set scanned (the `_index.md` **Groups** list at scan time, so a later group
addition can re-trigger per `_index.md`'s "A new group obligates a re-scan"), each group's
verdict, and every GAP's disposition (folded → named scenario, or dismissed with reason).

## Rules

- English, Gherkin in Markdown, DSL only (no technical details in steps)
- Main files: critical path (~27-34 total is a typical count, not a cap — prerequisite guards and side-effect/idempotency guards are always critical-path regardless of total), Extended files: edge cases
- **Load tests**: profile-driven. Read the **Load Challenge Profile** section in `ExpectedLoad.md` to identify this project's dominant load risk (Volume / Throughput / Latency / Big-data). Generate 1-3 scenarios per story that exercise the declared profile, using the matching assertion class and out-of-scope list from the catalog in `test-spec-format.md`. Skip the file entirely (set `Load = n/a`) for stories with no operation exercising the project's profile — one-shot per-user actions bounded by user count are the common case (login, registration, password reset, link API key)
- **Security**: generate stack-aware scenarios only — see relevance filtering and checklist in `test-spec-format.md`. Skip technologies not in the stack (NoSQL, LDAP, XXE). Skip cross-cutting concerns tested globally (security headers, CORS, HTTPS). Include IDOR for resource-by-ID endpoints (`tasks/{id}`, `boards/{id}`), JWT security for auth stories, input validation for task fields. Merge related scenarios (e.g., one SQL injection test covering all fields). Target 6-10 focused scenarios per story.
