---
name: test-frontend
description: Run frontend tests. Use when user wants to run frontend unit tests or mentions /test-frontend command.
---

# Run Frontend Tests

## Action

Read `ProductSpecification/technology.md` Conventions table for the frontend test command.

All tests:
```
{Frontend test command}
```

With argument (test filter):
```
{Frontend test command} {argument}
```

## Examples

- `skill="test-frontend"` - run all frontend tests
- `skill="test-frontend", args="registration.logic"` - run registration logic tests
- `skill="test-frontend", args="registration.api"` - run registration API tests
- `skill="test-frontend", args="login"` - run all login-related tests

## Output

Report the test results from output.
