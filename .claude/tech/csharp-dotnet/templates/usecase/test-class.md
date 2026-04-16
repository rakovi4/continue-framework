# Usecase Test Template -- C#/ASP.NET Core

> Universal rules: `.claude/templates/tdd/red-usecase.md`

## 3-Tier Locations

| Layer | Location |
|-------|----------|
| Test Class | `{Feature}/{Feature}Test.cs` |
| Statements | `Statements/{Feature}Statements.cs` |
| Scope | `Scope/{Feature}RequestScope.cs` |

## Tech-Specific Rules

- `[Fact(Skip = "RED: ...")]` on test methods
- Use `public class {Feature}Test` with `Should_{expected_behavior}` methods
- Add `[Trait("Description", "...")]` with Gherkin-style scenario text
- Not-implemented marker: `throw new NotImplementedException()`
- Empty values: `null` for optional fields, `Array.Empty<T>()` for collections

## Reference (read before generating)

- Test class: `backend/Usecase.Tests/{Feature}/{Feature}Test.cs`
- Statements: `backend/Usecase.Tests/Statements/{Feature}Statements.cs`
- Scope: `backend/Usecase.Tests/Scope/{Feature}RequestScope.cs`
- Base setup: `backend/Usecase.Tests/ApplicationTest.cs`
- TestData: `backend/Usecase.Tests/Scope/TestData.cs`
- Fake example: `backend/Usecase.Tests/Fake/{Feature}/Fake{Feature}Storage.cs`

## Update ApplicationTest

Add new use-case and statements fields to `ApplicationTest.cs` if needed (follow the existing sections).

## Key Paths

- Tests: `backend/Usecase.Tests/{Feature}/`
- Production: `backend/Usecase/`
- Base setup: `backend/Usecase.Tests/ApplicationTest.cs`
- Statements: `backend/Usecase.Tests/Statements/`
- Scopes: `backend/Usecase.Tests/Scope/`
- Fakes: `backend/Usecase.Tests/Fake/`
