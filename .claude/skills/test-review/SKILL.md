---
name: test-review
description: Review tests for strict assertions and complete omitted validation. Use when the user wants to improve test assertions or mentions /test-review.
---

# /test-review - Improve Test Assertions

## Usage

- `/test-review` — review all tests
- `/test-review {TestTarget}` — review one test target

## Available Templates

| Template | Purpose |
|----------|---------|
| `.claude/templates/testing/test-review-patterns.md` | Universal rules, anti-pattern catalog, assertion rules |
| `.claude/tech/{backend}/templates/testing/test-review-usecase.md` | Usecase test patterns (Statements purity, 3-tier DSL) |
| `.claude/tech/{backend}/templates/testing/test-review-rest.md` | REST controller test patterns (mock matching) |
| `.claude/tech/{backend}/templates/testing/test-review-storage.md` | Persistence test patterns |
| `.claude/tech/{backend}/templates/testing/test-review-acceptance.md` | Acceptance test patterns (HTTP response assertions) |
| `.claude/tech/{backend}/templates/testing/test-review-other.md` | Selenium, email, scheduling, security patterns |

## Workflow

Load `.claude/templates/workflow/quality-execution.md` for scope ownership,
parallel scheduling, retained workers, and compact phase evidence.

1. Resolve the test scope and layer (usecase / rest / storage / acceptance /
   selenium), including helpers and relevant collaborators. Load the matching
   technology template and `.claude/templates/workflow/test-review-checklist.md`.
2. Dispatch one independent `test-review-agent` per coherent scope. The worker
   must be independent of the test author, run all applicable A, P, S, and Se
   checks, then apply fixes under `.claude/agents/test-review-agent.md` for an
   unpartitioned scope. Se applies to selenium/frontend tests only. A small scope
   uses this same route.
3. For large scopes, partition by cohesive capability with all applicable checks
   per partition and a named cross-capability owner. Shared helpers have one
   write owner. Dispatch partitions read-only initially; gather every partition
   and cross-capability result before granting fixes. Workers must not nest
   fan-outs.
4. The worker runs the affected tests unless Stage 2 production work is concurrent;
   then it returns reviewed test paths and the coordinator owns joined execution.
   Review findings that affect required production behavior go to that writer.
   Return a distinct `/test-review` result. The coordinator may publish reviewed
   tests and dispatch RED refactoring while joined verification remains owed;
   keep the review gate pending until that verification completes.
5. Retain the quality worker for RED `/refactor` when available, preserving its
   context. It must stop after the review result. Only the coordinator's explicit
   `/refactor` dispatch after publication of reviewed tests starts that phase;
   skill invocations, evidence, and commits remain distinct.

Optional cluster fan-out requires coordinator justification from scope size and
available capacity. Dispatch `test-review-assertions-agent`,
`test-review-placement-agent`, `test-review-statements-agent`, and, for applicable
scopes, `test-review-selenium-agent` before awaiting any. Gather every result and
hand the findings to one owning `test-review-agent` for fixes. This exception does
not replace parallel scheduling of ready independent scopes.
