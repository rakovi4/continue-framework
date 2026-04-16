# Usecase Test Template -- Java/Spring

> Universal rules: `.claude/templates/tdd/red-usecase.md`

## 3-Tier Locations

| Layer | Location |
|-------|----------|
| Test Class | `{feature}/{Feature}UseCaseTest.java` |
| Statements | `statements/{Feature}Statements.java` |
| Scope | `scope/{Feature}RequestScope.java` |

## Tech-Specific Rules

- Extend `ApplicationTest`
- Add `@Disabled` annotation
- Use `@Description` with Gherkin format
- `@RequiredArgsConstructor` on Statements, `@Builder` + `@Default` on Scope
- Not-implemented marker: `throw new UnsupportedOperationException("Not implemented yet")`
- Empty values: `null` for nullable fields, `List.of()` for collections

## Reference (read before generating)

- Test class: `backend/usecase/src/test/java/com/example/usecase/task/create/CreateTaskUseCaseTest.java`
- Statements: `backend/usecase/src/test/java/com/example/usecase/statements/TaskStatements.java`
- Scope: `backend/usecase/src/test/java/com/example/usecase/scope/CreateTaskRequestScope.java`
- Base class: `backend/usecase/src/test/java/com/example/usecase/ApplicationTest.java`
- TestData: `backend/usecase/src/test/java/com/example/usecase/scope/TestData.java`
- Fake example: `backend/usecase/src/test/java/com/example/usecase/fake/task/FakeTaskStorage.java`

## Update ApplicationTest

Add new use-case and statements to `ApplicationTest.java` if needed (follow the existing `// ==================== USECASES ====================` and `// ==================== TEST STATEMENTS ====================` sections).

## Key Paths

- Tests: `backend/usecase/src/test/java/com/example/usecase/{feature}/`
- Production: `backend/usecase/src/main/java/com/example/usecase/{feature}/`
- Base class: `backend/usecase/src/test/java/com/example/usecase/ApplicationTest.java`
- Statements: `backend/usecase/src/test/java/com/example/usecase/statements/`
- Scopes: `backend/usecase/src/test/java/com/example/usecase/scope/`
- Fakes: `backend/usecase/src/test/java/com/example/usecase/fake/`
