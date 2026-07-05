# Database Storage Test Template -- C#/ASP.NET Core

## Test Class Rules

- Use `WebApplicationFactory<Program>` with test database + transaction rollback or fixture cleanup
- Inject the storage class under test via service provider
- Add `[Trait("Description", "Gherkin-style scenario")]` for scenario documentation
- Clean up test data in constructor / `Dispose()` (xUnit) or `[SetUp]` / `[TearDown]` (NUnit)

## DB-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| `return null` | `result.Should().NotBeNull()` or `result.Should().Be(expected)` |
| `return Enumerable.Empty<T>()` | `result.Should().NotBeEmpty()` or `result.Should().BeEquivalentTo(expected)` |

## Reference (read before generating)

- Test example: `backend/Adapters/Storage.Tests/Access/{Feature}/{Feature}StorageTest.cs`
- Test setup: `backend/Adapters/Storage.Tests/TestFixture.cs`
- Storage example: `backend/Adapters/Storage/Access/{Feature}/{Feature}Storage.cs`
- Entity example: `backend/Adapters/Storage/Model/{Feature}/{Feature}Entity.cs`

## Naming Convention

- Test file: `{Entity}Storage{Method}Test.cs`
- Test method: `Should_{expected_behavior}`

## Key Paths

- Tests: `backend/Adapters/Storage.Tests/Access/`
- Production: `backend/Adapters/Storage/Access/`
- Entities: `backend/Adapters/Storage/Model/`
- Migrations: `backend/Adapters/Storage/Migrations/`
