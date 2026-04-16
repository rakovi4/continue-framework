# Security Adapter Test Template

## Test Class Rules

- Pure unit tests — NO Express app context
- Mock dependencies with `vi.fn()` / `jest.fn()`
- Construct the class under test manually in `beforeEach`
- Use `FakeClock` or `Date.now = vi.fn()` for deterministic time
- Use `describe("Feature: ...")` with Gherkin-style description

## Security-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Wrong mock interaction | Mock verification failure |

## Reference (read before generating)

- Existing test: `backend/adapters/security/src/__tests__/middleware/SessionAuthMiddleware.test.ts`
- JWT service: `backend/adapters/security/src/JwtService.ts`
- Config: `backend/adapters/security/src/JwtConfig.ts`
- Middleware: `backend/adapters/security/src/middleware/SessionAuthMiddleware.ts`

## Test Pattern

1. **Setup** (`beforeEach`): create mocks, fixed clock, construct class under test
2. **Mock**: `vi.mocked(dependency.method).mockReturnValue(value)`
3. **Execute**: call method under test
4. **Assert**: use `expect()` with descriptive messages
5. **Verify** (optional): `expect(mock.method).toHaveBeenCalledWith(args)` for side-effect verification

## Naming Convention

- Test file: `{ComponentName}.test.ts`
- Test case: `it("should {expected behavior}")`

## Key Paths

- Tests: `backend/adapters/security/src/__tests__/`
- Production: `backend/adapters/security/src/`
