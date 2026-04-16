# SQLite Storage Implementation Template -- C++/CMake

## Rules

- Replace stub implementation with actual logic using prepared SQL statements
- Map between row structs and domain objects using existing conversion methods
- Use transactions for write operations (begin/commit/rollback)

## Reference (read before generating)

- Storage example: `backend/adapters/sqlite/src/access/task/sqlite_task_storage.cpp`
- Row example: `backend/adapters/sqlite/src/entity/task/task_row.h`
- Migration example: `backend/adapters/sqlite/src/migrations/`

## SQLite Prepared Statement Patterns

Use `sqlite3_prepare_v2`, `sqlite3_bind_*`, and `sqlite3_step` for all queries. Common patterns:

| Operation | Pattern |
|-----------|---------|
| SELECT by column | `"SELECT ... FROM table WHERE column = ?"` + `sqlite3_bind_text/int` |
| INSERT | `"INSERT INTO table (...) VALUES (?, ?, ?)"` + bind parameters |
| UPDATE | `"UPDATE table SET ... WHERE id = ?"` + bind parameters |
| EXISTS check | `"SELECT COUNT(*) FROM table WHERE ..."` + check `sqlite3_column_int > 0` |

## Row Conversion

- `TaskRow::to_domain()` — convert row to domain object
- `TaskRow::from_domain(const Task&)` — convert domain to row

## Key Paths

- Storage: `backend/adapters/sqlite/src/access/`
- Row structs: `backend/adapters/sqlite/src/entity/`
- Migrations: `backend/adapters/sqlite/src/migrations/`
