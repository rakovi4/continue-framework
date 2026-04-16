# SQLite Storage Test Template -- C++/CMake

## Test Class Rules

- Use Google Test fixture with in-memory SQLite database (`:memory:`)
- Run schema migrations in `SetUp()` to create tables
- Construct storage class under test with the in-memory database connection
- Use descriptive test names with `DISABLED_` prefix

## SQLite-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| `return std::nullopt;` | `EXPECT_TRUE(result.has_value())` fails |
| `return {};` (empty vector) | `EXPECT_FALSE(result.empty())` fails |

## Reference (read before generating)

- Test example: `backend/adapters/sqlite/tests/access/task/sqlite_task_storage_save_test.cpp`
- Test fixture base: `backend/adapters/sqlite/tests/sqlite_test_fixture.h`
- Storage example: `backend/adapters/sqlite/src/access/task/sqlite_task_storage.cpp`
- Row example: `backend/adapters/sqlite/src/entity/task/task_row.h`

## Naming Convention

- Test class: `Sqlite{Entity}Storage{Method}Test`
- Test method: `should_{expected_behavior}`

## Key Paths

- Tests: `backend/adapters/sqlite/tests/access/`
- Production: `backend/adapters/sqlite/src/access/`
- Row structs: `backend/adapters/sqlite/src/entity/`
- Migrations: `backend/adapters/sqlite/src/migrations/`
