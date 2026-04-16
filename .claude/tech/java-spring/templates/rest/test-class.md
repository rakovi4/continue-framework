# Controller Test Template -- Java/Spring

> Universal rules: `.claude/templates/tdd/red-rest.md`

## Tech-Specific Rules

- Implement `RestTest` interface
- Annotate with `@AutoConfigureMockMvc`
- Use `@MockBean` for use-case classes
- Create exactly ONE `@Test` method, add `@Disabled`
- Use `@SneakyThrows` for cleaner exception handling
- Setup: `when(...).thenReturn(...)`
- Execute: HTTP request via MockMvc
- Verify: compare JSON response against expected template

## Expected Response JSON

Create in `backend/adapters/rest/src/test/resources/{feature}/` with `%s` placeholders for dynamic values.

## Reference (read before generating)

- Test example: `backend/adapters/rest/src/test/java/com/example/rest/controller/auth/TaskControllerTest.java`
- RestTest interface: `backend/adapters/rest/src/test/java/com/example/rest/RestTest.java`
- Request DTO example: `backend/adapters/rest/src/main/java/com/example/rest/dto/task/CreateTaskRequestDto.java`
- JSON template example: `backend/adapters/rest/src/test/resources/` (look for existing JSON files)

## Key Paths

- Tests: `backend/adapters/rest/src/test/java/com/example/rest/controller/`
- Production: `backend/adapters/rest/src/main/java/com/example/rest/controller/`
- DTOs: `backend/adapters/rest/src/main/java/com/example/rest/dto/`
- JSON templates: `backend/adapters/rest/src/test/resources/`
