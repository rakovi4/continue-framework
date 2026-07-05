# Database Storage Test Template

## Test Class Rules

- Use `RefreshDatabase` or `DatabaseTransactions` trait for test isolation
- Inject the storage class under test
- Add `#[TestDox('...')]` with Gherkin-style description
- Clean up test data via trait or explicit `setUp()`/`tearDown()`

## DB-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| `return null` | `assertNotNull` or `assertEquals($expected, $result)` |
| `return []` | `assertNotEmpty` or `assertEquals($expected, $result)` |

## Reference (read before generating)

- Test example: `backend/adapters/storage/tests/Access/{Feature}/{Feature}StorageTest.php`
- Test setup: `backend/adapters/storage/tests/TestCase.php`
- Storage example: `backend/adapters/storage/src/Access/{Feature}/{Feature}Storage.php`
- Model example: `backend/adapters/storage/src/Model/{Feature}/{Feature}Model.php`

## Naming Convention

- Test file: `{Entity}Storage{Method}Test.php`
- Test method: `test_should_{expected_behavior}`

## Key Paths

- Tests: `backend/adapters/storage/tests/Access/`
- Production: `backend/adapters/storage/src/Access/`
- Models: `backend/adapters/storage/src/Model/`
- Migrations: `database/migrations/`
