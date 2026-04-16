# Acceptance Test Template -- Node/TS/Express

> Universal structure and rules: `.claude/templates/tdd/red-acceptance.md`

## Framework Rules

- Test file imports base test setup (`AbstractBackendTest` or `AbstractUiTest` helpers)
- `describe.skip("TDD Red Phase - Not yet implemented")` for new tests
- Not-implemented marker in Statements: `throw new Error("Not implemented")`

## Test Types

| Type | Base Setup | File Pattern |
|------|------------|--------------|
| Backend API | `AbstractBackendTest` helpers | `tests/backend/` |
| Frontend UI | `AbstractUiTest` helpers | `tests/frontend/` |

## Reference Paths

- Test example: `acceptance/src/__tests__/backend/{feature}/{Feature}Acceptance.test.ts`
- Base setup: `acceptance/src/__tests__/backend/AbstractBackendTest.ts`
- Statements example: `acceptance/src/statements/{Feature}Statements.ts`
- Client: `acceptance/src/clients/application/ApplicationClient.ts`
- TestData: `acceptance/src/statements/TestData.ts`

## Key Paths

- Backend tests: `acceptance/src/__tests__/backend/`
- Statements: `acceptance/src/statements/`
- Client: `acceptance/src/clients/application/`
- DTOs: `acceptance/src/clients/application/dto/`
