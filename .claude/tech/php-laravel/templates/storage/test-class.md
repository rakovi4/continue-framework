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

- Test example: `backend/adapters/db/tests/Access/{Feature}/{Feature}StorageTest.php`
- Test setup: `backend/adapters/db/tests/TestCase.php`
- Storage example: `backend/adapters/db/src/Access/{Feature}/{Feature}Storage.php`
- Model example: `backend/adapters/db/src/Model/{Feature}/{Feature}Model.php`

## Naming Convention

- Test file: `{Entity}Storage{Method}Test.php`
- Test method: `test_should_{expected_behavior}`

## Key Paths

- Tests: `backend/adapters/db/tests/Access/`
- Production: `backend/adapters/db/src/Access/`
- Models: `backend/adapters/db/src/Model/`
- Migrations: `database/migrations/`
