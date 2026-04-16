# Acceptance Test Template -- PHP/Laravel

> Universal structure and rules: `.claude/templates/tdd/red-acceptance.md`

## Framework Rules

- Extends `AbstractBackendTest` (backend) or `AbstractUiTest` (frontend)
- Skip via `$this->markTestSkipped('TDD Red Phase - Not yet implemented')` in `setUp()`
- Not-implemented marker in Statements: `throw new \RuntimeException('Not implemented')`
- Add `#[TestDox('...')]` with Gherkin-style scenario
- Statements are plain classes instantiated in test `setUp()` or injected via Laravel container

## Test Types

| Type | Base Class | Group |
|------|------------|-------|
| Backend API | `AbstractBackendTest` | `@group backend` |
| Frontend UI | `AbstractUiTest` | `@group frontend` |

## Reference Paths

- Test example: `acceptance/tests/backend/{feature}/{Feature}AcceptanceTest.php`
- Base class: `acceptance/tests/backend/AbstractBackendTest.php`
- Statements example: `acceptance/statements/{Feature}Statements.php`
- Client: `acceptance/clients/application/ApplicationClient.php`
- TestData: `acceptance/statements/TestData.php`

## Key Paths

- Backend tests: `acceptance/tests/backend/`
- Statements: `acceptance/statements/`
- Client: `acceptance/clients/application/`
- DTOs: `acceptance/clients/application/dto/`
