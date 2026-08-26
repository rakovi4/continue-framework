# Acceptance Test Template -- C#/ASP.NET Core

> Universal structure and rules: `.claude/templates/tdd/red-acceptance.md`

## Framework Rules

- Inherits from `AbstractBackendTest` (backend) or `AbstractUiTest` (frontend)
- Group cases in one scenario-named class; apply the same `[Fact(Skip = "TDD Red Phase - Not yet implemented")]` to every method and remove the complete marker set atomically in Stage 3
- Not-implemented marker in Statements: `throw new NotImplementedException()`
- Add `[Trait("Description", "Gherkin-style scenario")]` for scenario documentation
- Statements receive dependencies via constructor injection from test fixture

## Test Types

| Type | Base Class | Trait |
|------|------------|-------|
| Backend API | `AbstractBackendTest` | `[Trait("Category", "Backend")]` |
| Frontend UI | `AbstractUiTest` | `[Trait("Category", "Frontend")]` |

## Reference Paths

- Test example: `acceptance/Tests/Backend/{Feature}/{Feature}AcceptanceTest.cs`
- Base class: `acceptance/Tests/Backend/AbstractBackendTest.cs`
- Statements example: `acceptance/Statements/{Feature}Statements.cs`
- Client: `acceptance/Clients/Application/ApplicationClient.cs`
- TestData: `acceptance/Statements/TestData.cs`

## Key Paths

- Backend tests: `acceptance/Tests/Backend/`
- Statements: `acceptance/Statements/`
- Client: `acceptance/Clients/Application/`
- DTOs: `acceptance/Clients/Application/Dto/`
