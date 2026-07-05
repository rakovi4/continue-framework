# Database Storage Test Template

## Test Class Rules

- Use `@pytest.mark.django_db` with `TransactionTestCase` or fixture-based cleanup
- Inject the storage class under test
- Use class-level docstring with Gherkin-style description
- Clean up test data in `setup_method` / `teardown_method` or pytest fixtures

## DB-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| `return None` | `assert result is not None` or `assert result == expected` |
| `return []` | `assert result != []` or `assert result == expected` |

## Reference (read before generating)

- Test example: `backend/adapters/storage/tests/access/{feature}/test_{feature}_storage.py`
- Test setup: `backend/adapters/storage/tests/conftest.py`
- Storage example: `backend/adapters/storage/src/access/{feature}/{feature}_storage.py`
- Model example: `backend/adapters/storage/src/model/{feature}/{feature}_model.py`

## Naming Convention

- Test file: `test_{entity}_storage_{method}.py`
- Test method: `test_should_{expected_behavior}`

## Key Paths

- Tests: `backend/adapters/storage/tests/access/`
- Production: `backend/adapters/storage/src/access/`
- Models: `backend/adapters/storage/src/model/`
- Migrations: `backend/adapters/storage/migrations/`
