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

1. Load `.claude/agents/test-review-agent.md`
2. **Run the mandatory checklist** defined in the agent — grep each pattern, paste results. Fix violations before proceeding.
3. Load `.claude/templates/testing/test-review-patterns.md` for universal rules and anti-pattern catalog
4. Determine the layer of the test being reviewed, load the matching tech-specific file (see agent Reference section)
5. Verify all response fields have strict assertions (read DTO, check every field)
6. Replace loose assertions with exact assertions on parsed fields
7. Run tests via `/test-runner` to verify behavior unchanged
