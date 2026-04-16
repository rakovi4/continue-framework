# Acceptance Test Template -- Java/Spring

> Universal structure and rules: `.claude/templates/tdd/red-acceptance.md`

## Framework Rules

- Extends `AbstractBackendTest` (backend) or `AbstractUiTest` (frontend)
- `@Disabled("TDD Red Phase - Not yet implemented")` for new tests
- Not-implemented marker in Statements: `throw new UnsupportedOperationException()`
- `@Description` with Gherkin-style scenario
- Statements annotated with `@Service`

## Test Types

| Type | Base Class | Tag |
|------|------------|-----|
| Backend API | `AbstractBackendTest` | `@Tag("backend")` |
| Frontend UI | `AbstractUiTest` | `@Tag("frontend")` |

## Reference Paths

- Test example: `acceptance/src/test/java/com/example/acceptance/tests/backend/createTask/CreateTaskAcceptanceTest.java`
- Base class: `acceptance/src/test/java/com/example/acceptance/tests/backend/AbstractBackendTest.java`
- Statements example: `acceptance/src/test/java/com/example/acceptance/statements/TaskStatements.java`
- Client: `acceptance/src/test/java/com/example/acceptance/clients/application/ApplicationClient.java`
- TestData: `acceptance/src/test/java/com/example/acceptance/statements/TestData.java`

## Key Paths

- Backend tests: `acceptance/src/test/java/com/example/acceptance/tests/backend/`
- Statements: `acceptance/src/test/java/com/example/acceptance/statements/`
- Client: `acceptance/src/test/java/com/example/acceptance/clients/application/`
- DTOs: `acceptance/src/test/java/com/example/acceptance/clients/application/dto/`
