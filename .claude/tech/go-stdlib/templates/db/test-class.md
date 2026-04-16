# Database Storage Test Template -- Go/stdlib

## Test Class Rules

- Use test database with transaction rollback or table truncation cleanup
- Inject the storage struct under test
- Use `t.Run("scenario description", ...)` subtests with Gherkin-style description
- Clean up test data in setup/teardown helpers

## DB-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| `return nil, nil` (not found) | `Expected value to not be nil` or `Expected values to be equal` |
| `return []T{}, nil` | `Expected slice not to be empty` or `Expected slices to match` |

## Reference (read before generating)

- Test example: `backend/adapters/db/{feature}/{feature}_storage_test.go`
- Test setup: `backend/adapters/db/testutil/db_test_setup.go`
- Storage example: `backend/adapters/db/{feature}/{feature}_storage.go`
- Entity example: `backend/adapters/db/{feature}/{feature}_row.go`

## Naming Convention

- Test file: `{entity}_storage_test.go`
- Test function: `Test{Entity}Storage_{Method}(t *testing.T)`
- Subtest: `t.Run("should {expected behavior}", ...)`

## Key Paths

- Tests: `backend/adapters/db/{feature}/`
- Production: `backend/adapters/db/{feature}/`
- Entities/Rows: `backend/adapters/db/{feature}/`
- Migrations: `backend/adapters/db/migrations/`
