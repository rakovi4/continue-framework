---
name: test-usecase
description: Run use-case module tests quickly. Use when user wants to run use-case tests or mentions /test-usecase command.
---

# Run Use-Case Tests

## Action

Read `ProductSpecification/technology.md` Conventions table for the backend test command pattern.

Without argument — run all usecase tests:
```
{Backend test command} with module = usecase
```

With argument (test filter) — run filtered:
```
{Backend test command} with module = usecase, filtered to *{argument}*
```

## Output

Report the test results from output.
