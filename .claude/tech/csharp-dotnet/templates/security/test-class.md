# Security Adapter Test Template -- C#/ASP.NET Core

## Test Class Rules

- Pure unit tests — NO `WebApplicationFactory` or ASP.NET Core context
- Mock dependencies with `Mock<T>()` (Moq) or `Substitute.For<T>()` (NSubstitute)
- Construct the class under test manually in test constructor (xUnit) or `[SetUp]` (NUnit)
- Use `FakeClock` or mock `IClock` for deterministic time
- Add `[Trait("Description", "Gherkin-style scenario")]` for scenario documentation

## Security-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Wrong mock interaction | Mock verification failure |

## Reference (read before generating)

- Existing test: `backend/Adapters/Security.Tests/Middleware/SessionAuthMiddlewareTest.cs`
- JWT service: `backend/Adapters/Security/JwtService.cs`
- Config: `backend/Adapters/Security/JwtConfig.cs`
- Middleware: `backend/Adapters/Security/Middleware/SessionAuthMiddleware.cs`

## Test Pattern

1. **Setup** (constructor / `[SetUp]`): create mocks, fixed clock, construct class under test
2. **Mock**: `mockDependency.Setup(x => x.Method(args)).Returns(value)`
3. **Execute**: call method under test
4. **Assert**: use `actual.Should().Be(expected)` with descriptive assertions
5. **Verify** (optional): `mockDependency.Verify(x => x.Method(args), Times.Once)` for side-effect verification

## Naming Convention

- Test file: `{ComponentName}Test.cs`
- Test method: `Should_{expected_behavior}`

## Key Paths

- Tests: `backend/Adapters/Security.Tests/`
- Production: `backend/Adapters/Security/`
