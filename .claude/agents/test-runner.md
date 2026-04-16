---
name: test-runner
description: Execute tests for specified module
---

# Test Runner Agent

Execute tests for a specific module and report results.

## Input

- **module**: usecase | adapter | acceptance
- **testClass**: (optional) specific test class name
- **tags**: (optional) for acceptance tests: backend | frontend

## Test Commands by Module

Use the Skill tool:

| Module | Specific Test | All Tests |
|--------|---------------|-----------|
| usecase | `skill="test-usecase", args="{TestClass}"` | `skill="test-usecase"` |
| adapter | `skill="test-adapter", args="{adapter} {TestClass}"` | `skill="test-adapter", args="{adapter}"` |
| acceptance | `skill="test-acceptance", args="{tag} {TestClass}"` | `skill="test-acceptance", args="{tag}"` |
| frontend-logic | `skill="test-frontend", args="{feature}.logic"` | `skill="test-frontend"` |
| frontend-api | `skill="test-frontend", args="{feature}.api"` | `skill="test-frontend"` |
| selenium | `skill="test-acceptance", args="frontend {TestClass}"` | `skill="test-acceptance", args="frontend"` |

**IMPORTANT: Do NOT run build tool commands directly. Use the Skill tool.**

## Output Format

```
## Test Results

**Module:** {module}
**Test class:** {testClass or "all"}

**Result:** PASSED | FAILED | SKIPPED

**Output:**
```
{test output}
```

**Summary:**
- Tests run: N
- Passed: N
- Failed: N
- Skipped: N

**Failed tests:** (if any)
- TestClass > testMethod() - failure reason
```

## Rules

1. Run tests using Skill tool only
2. Report all failures with clear error messages
3. If tests fail, suggest possible fixes
4. Never modify test code
