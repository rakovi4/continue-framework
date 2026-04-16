# Usecase Test Template -- PHP/Laravel

> Universal rules: `.claude/templates/tdd/red-usecase.md`

## 3-Tier Locations

| Layer | Location |
|-------|----------|
| Test Class | `{Feature}/{Feature}UsecaseTest.php` |
| Statements | `Statements/{Feature}Statements.php` |
| Scope | `Scope/{Feature}RequestScope.php` |

## Tech-Specific Rules

- Skip via `$this->markTestSkipped('RED: ...')` in test method or `setUp()`
- Use `class {Feature}UsecaseTest extends TestCase` with `test_should_{expected_behavior}` methods
- Add `#[TestDox('...')]` with Gherkin-style scenario text
- Not-implemented marker: `throw new \RuntimeException('Not implemented')`
- Empty values: `null` for optional fields, `[]` for collections

## Reference (read before generating)

- Test class: `backend/usecase/tests/{Feature}/{Feature}UsecaseTest.php`
- Statements: `backend/usecase/tests/Statements/{Feature}Statements.php`
- Scope: `backend/usecase/tests/Scope/{Feature}RequestScope.php`
- Base setup: `backend/usecase/tests/TestCase.php`
- TestData: `backend/usecase/tests/Scope/TestData.php`
- Fake example: `backend/usecase/tests/Fake/{Feature}/Fake{Feature}Storage.php`

## Update TestCase.php

Add new use-case and statements construction to `TestCase.php` if needed (follow the existing sections).

## Key Paths

- Tests: `backend/usecase/tests/{Feature}/`
- Production: `backend/usecase/src/{Feature}/`
- Base setup: `backend/usecase/tests/TestCase.php`
- Statements: `backend/usecase/tests/Statements/`
- Scopes: `backend/usecase/tests/Scope/`
- Fakes: `backend/usecase/tests/Fake/`
