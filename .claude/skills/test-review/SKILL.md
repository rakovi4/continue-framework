---
name: test-review
description: Review tests to replace loose validation (contains, isNotNull, isNotEmpty) with strict validation (isEqualTo on parsed fields). Use when user wants to improve test assertions or mentions /test-review command.
---

# /test-review - Improve Test Assertions

## Usage
```
/test-review                           # Review all tests
/test-review LoginControllerTest  # Specific test file
```

## Available Templates

| Template | Purpose |
|----------|---------|
| `.claude/templates/testing/test-review-patterns.md` | Universal rules, anti-pattern catalog, assertion rules |
| `.claude/tech/{backend}/templates/testing/test-review-usecase.md` | Usecase test patterns (Statements purity, 3-tier DSL) |
| `.claude/tech/{backend}/templates/testing/test-review-rest.md` | REST controller test patterns (mock matching) |
| `.claude/tech/{backend}/templates/testing/test-review-h2.md` | Persistence test patterns |
| `.claude/tech/{backend}/templates/testing/test-review-acceptance.md` | Acceptance test patterns (HTTP response assertions) |
| `.claude/tech/{backend}/templates/testing/test-review-other.md` | Selenium, email, scheduling, security patterns |

## Workflow

Scatter–gather: **parallel read-only detectors** find violations, then a **single
serial fixer** applies them. The detectors never edit — only the fixer writes, one
file at a time — so there are no concurrent writes to shared Statements files.

1. **Determine the test's layer** (usecase / rest / h2 / acceptance / selenium) —
   this selects the tech file each detector loads and whether the selenium
   detector runs.
2. **Dispatch the detectors in parallel** (single message, multiple agent calls).
   Each runs only its cluster of `.claude/templates/workflow/test-review-checklist.md`
   and returns a findings table:
   - `test-review-assertions-agent` — cluster A (assertion strictness)
   - `test-review-placement-agent` — cluster P (test-class vs Statements placement)
   - `test-review-statements-agent` — cluster S (Statements internal quality)
   - `test-review-selenium-agent` — cluster Se — **only for selenium/frontend tests**; skip for pure backend tests.
3. **Gather + fix:** hand all findings to `.claude/agents/test-review-agent.md`
   (the serial fixer). It merges, dedups, applies fixes one file at a time, runs
   `/test-runner`, and prints the filled `test-review-output-format.md`.

### Small-file shortcut

If the target test is small with very few assertions, skip the fan-out and run a
single `test-review-agent` pass over the whole checklist — the detector
orchestration + merge overhead can exceed the single-agent cost on tiny files.
