# Security Adapter Test Template

## Test Class Rules

- Use `@ExtendWith(MockitoExtension.class)` — NO Spring context
- Mock dependencies with `@Mock` (e.g., `JwtService`, `SessionStorage`)
- Construct the class under test manually in `@BeforeEach`
- Use `Clock.fixed(NOW, ZoneOffset.UTC)` for deterministic time
- Use `@DisplayName` with Gherkin-style description

## Security-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Wrong mock interaction | Mockito verification failure |

## Reference (read before generating)

- Existing test: `backend/adapters/security/src/test/java/com/example/security/filter/SessionAuthenticationFilterTest.java`
- JWT service: `backend/adapters/security/src/main/java/com/example/security/JwtService.java`
- Properties: `backend/adapters/security/src/main/java/com/example/security/JwtProperties.java`
- Filter: `backend/adapters/security/src/main/java/com/example/security/filter/SessionAuthenticationFilter.java`

## Test Pattern

1. **Setup** (`@BeforeEach`): create mocks, fixed Clock, construct class under test
2. **Mock**: `when(dependency.method()).thenReturn(value)`
3. **Execute**: call method under test
4. **Assert**: use AssertJ with `.as("description")` on every assertion
5. **Verify** (optional): `verify(mock).method(args)` for side-effect verification

## Naming Convention

- Test class: `{ComponentName}Test.java`
- Test method: `should{ExpectedBehavior}` or descriptive camelCase

## Key Paths

- Tests: `backend/adapters/security/src/test/java/com/example/security/`
- Production: `backend/adapters/security/src/main/java/com/example/security/`
