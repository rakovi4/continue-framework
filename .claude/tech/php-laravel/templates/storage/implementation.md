# Database Storage Implementation Template

## Rules

- Replace stub implementation with actual logic using Eloquent ORM
- Map between Eloquent model and domain objects using conversion methods
- Use `DB::transaction()` for write operations when needed

## Reference (read before generating)

- Storage example: `backend/adapters/db/src/Access/{Feature}/{Feature}Storage.php`
- Model example: `backend/adapters/db/src/Model/{Feature}/{Feature}Model.php`
- Migration directory: `database/migrations/`

## Eloquent Query Methods

| Operation | Code |
|-----------|------|
| Find by field | `TaskModel::where('email', $email)->firstOrFail()` |
| Find many | `TaskModel::where('board_id', $boardId)->get()` |
| Create | `TaskModel::create(TaskModel::fromDomain($domain)->toArray())` |
| Check exists | `TaskModel::where('email', $email)->exists()` |
| Eager load | `TaskModel::with('board')->where('board_id', $boardId)->get()` |
| Nested eager load | `BoardModel::with('columns.tasks')->findOrFail($boardId)` |

## Model Conversion

- `$model->toDomain()` -- convert Eloquent model to domain object
- `ModelClass::fromDomain($domain)` -- static method to convert domain to Eloquent model

## Key Paths

- Storage: `backend/adapters/db/src/Access/`
- Models: `backend/adapters/db/src/Model/`
- Migrations: `database/migrations/`
