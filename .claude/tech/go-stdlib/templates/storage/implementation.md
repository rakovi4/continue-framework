# Database Storage Implementation Template -- Go/stdlib

## Rules

- Replace stub implementation with actual logic using pgx/sqlc or database/sql
- Map between row structs and domain objects using conversion methods
- Wrap write operations in transactions when needed (via `pgx.Tx` or `sql.Tx`)

## Reference (read before generating)

- Storage example: `backend/adapters/db/{feature}/{feature}_storage.go`
- Row/entity example: `backend/adapters/db/{feature}/{feature}_row.go`
- DB config: `backend/adapters/db/config/`

## Query Examples (pgx)

| Operation | Code |
|-----------|------|
| Find by field | `row := pool.QueryRow(ctx, "SELECT ... WHERE email=$1", email)` |
| Find many | `rows, err := pool.Query(ctx, "SELECT ... WHERE board_id=$1", boardID)` |
| Create | `_, err := pool.Exec(ctx, "INSERT INTO ...", row.ID, row.Name)` |
| Check exists | `pool.QueryRow(ctx, "SELECT COUNT(*) FROM ... WHERE email=$1", email).Scan(&count)` |

## Query Examples (sqlc)

| Operation | Code |
|-----------|------|
| Find by field | `row, err := queries.FindTaskByEmail(ctx, email)` |
| Find many | `rows, err := queries.ListTasksByBoard(ctx, boardID)` |
| Create | `err := queries.CreateTask(ctx, sqlc.CreateTaskParams{...})` |
| Check exists | `exists, err := queries.TaskExistsByEmail(ctx, email)` |

## Key Paths

- Storage: `backend/adapters/db/{feature}/`
- Row structs: `backend/adapters/db/{feature}/`
- Migrations: `backend/adapters/db/migrations/`
- sqlc config: `backend/adapters/db/sqlc.yaml`
