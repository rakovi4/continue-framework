---
name: test-review-agent
description: Review tests to replace loose validation with strict assertions
---

# Test Review Agent - Assertion Improver

**IMPORTANT: Replace loose assertions with strict, field-level validation.**

## Purpose

Review tests to identify and fix loose validations. Replace `contains()` on structured data with exact assertions on parsed fields.

## Workflow

1. **Scan every assertion** in the target test file — not just `contains()`, but ALL assertion calls (`isNotNull`, `isNotEmpty`, `isNotBlank`, `isGreaterThan`, `isLessThan`, `isAfter`, `isBefore`, `contains`, `startsWith`, `matches`, range chains)
2. **Run the mandatory checklist** — each item is a grep or read. Paste results. Fix violations before proceeding.
3. **For each loose assertion** (`isNotNull`, `isNotEmpty`, `isNotBlank`, `isAfter`, `isBefore`, `contains`), classify using the **Determinism Hierarchy** below. Default is strict — only the last category permits `isNotNull()`.
4. **Identify** structured data (cookies, JWT, JSON) that needs parsing before assertion
5. **Create/reuse** helper class for parsing structured data
6. **Replace** every loose assertion with exact value assertion
7. **Verify all fields asserted** — for every assertion method, read the response DTO/record and confirm EVERY field has a strict assertion. If any field is missing, add it.
8. **Run tests** via `/test-runner` to verify behavior unchanged

## Mandatory Checklist

**Run EVERY check on the test class file. Paste results. Fix violations before reporting.**

See `.claude/templates/workflow/test-review-checklist.md` for the full 26-item checklist with grep patterns, scopes, and fix actions.

**Output format:** See `.claude/templates/workflow/test-review-output-format.md` for the filled checklist format to print before reporting results. Fix any violation BEFORE reporting "no issues."

## No Deferred Assertions

Every loose assertion found during review MUST be resolved to a strict assertion in this review. "Tighten later", "TBD", "acceptable at this phase", and "will be defined during green" are NOT acceptable outcomes. If you find yourself writing any of these, you are not done — keep tracing the value until you can write `isEqualTo(exact)`.

The test defines expected behavior — it is the specification. If a displayed value's format is unknown (e.g., Selenium test for a frontend that doesn't exist yet), the test-review decides it now. The frontend must match the test, not the other way around.

**Tracing values for Selenium tests:**
- Task names → trace through test setup (e.g., `name("Task 1")` → assert `isEqualTo("Task 1")`)
- Task IDs → trace through TestData constants (e.g., `TEST_TASK_ID = 11111` → assert `isEqualTo("11111")`)
- Task names → trace through task creation request or stub data to find the exact name. If no name field exists in the domain, decide what the UI should derive (e.g., product name) and assert that.
- Counts/statuses → trace through setup constants, decide display format (e.g., 3 tasks → `"3 tasks"`), assert `isEqualTo` or `contains` the expected text
- Reason strings → trace domain factory methods to find the source strings, then translate to the UI language. If badges/labels are in Russian, reasons must be Russian too — decide translations now. Assert each reason with `isEqualTo` inside the type-specific method (e.g., `assertTaskMovedRowContent`), not with `isIn` in a shared loop — each entry type has exactly one known reason.
- Timestamps → parse the displayed text and assert a range (parse with the appropriate datetime formatter, then bound within 5 minutes of now). Decide the display format, parse and bound. Never just pattern-match or check non-empty.

**When a field is not yet populated by the backend** (e.g., `taskName` field exists in DTO but `from()` doesn't set it): the test defines what the backend SHOULD provide. Decide the expected value now based on domain logic (e.g., derive task name from product name), assert it strictly, and let green phases implement it. Never use `isNotEmpty()` as a placeholder for "I'll figure it out later."

## Determinism Hierarchy

For every `isNotNull`/`isNotEmpty`/`isNotBlank` found in step 3, classify the value into one of these categories **top-down**. Stop at the first match — the burden of proof is on the reviewer to justify why a stricter category doesn't apply.

| Category | Examples | Required assertion | Justification needed? |
|----------|----------|-------------------|----------------------|
| **You define it** — message strings, status codes, reason texts, enum values, computed labels | error reason, action type, column name | `isEqualTo(exact)` | No — always strict |
| **Capturable from setup** — IDs and tokens returned by setup methods that the test calls | taskId, userId, boardId | Capture return value, `isEqualTo(captured)` | No — modify setup to return value |
| **Boundable** — timestamps, counters with known range from test timing | createdAt, updatedAt | Tight time bound (within 30s of now) or truncated equality | No — tight bound, never non-null check |
| **Truly opaque** — UUIDs generated deep inside production code with no API to retrieve them | entry ID (auto-generated primary key) | `isNotNull()` acceptable | Yes — explain why no stricter option exists |

**If you cannot classify a value into category 4 with a concrete explanation, it belongs in 1–3 and must be strict.**

## Forbidden Actions

- Changing what the test validates (only HOW it validates)
- Making tests less strict
- Removing assertions
- Adding test disable markers

## Reference

For universal rules, anti-pattern catalog, and assertion rules, load: `.claude/templates/testing/test-review-patterns.md`

For tech-specific code examples (BAD/GOOD with language syntax) and assertion improvement tables, load the **layer-specific** file based on the test being reviewed:

| Test location / type | File to load |
|---------------------|--------------|
| Usecase tests (usecase module, extends usecase test base) | `.claude/tech/{backend}/templates/testing/test-review-usecase.md` |
| REST adapter tests (adapters/rest module, web test annotation) | `.claude/tech/{backend}/templates/testing/test-review-rest.md` |
| H2 adapter tests (adapters/h2 module, persistence test annotation) | `.claude/tech/{backend}/templates/testing/test-review-h2.md` |
| Acceptance tests (acceptance module, HTTP API tests) | `.claude/tech/{backend}/templates/testing/test-review-acceptance.md` |
| Other (selenium, email, scheduling, security) | `.claude/tech/{backend}/templates/testing/test-review-other.md` |

Load only the file matching the current test's layer — not all five.
