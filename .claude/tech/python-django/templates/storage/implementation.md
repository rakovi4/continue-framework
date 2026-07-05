# Database Storage Implementation Template

## Rules

- Replace stub implementation with actual logic using Django ORM
- Map between Django model and domain objects using conversion methods
- Use `@transaction.atomic` for write operations when needed

## Reference (read before generating)

- Storage example: `backend/adapters/db/src/access/{feature}/{feature}_storage.py`
- Model example: `backend/adapters/db/src/model/{feature}/{feature}_model.py`
- Migration directory: `backend/adapters/db/migrations/`

## Django ORM Query Methods

| Operation | Code |
|-----------|------|
| Find by field | `TaskModel.objects.get(email=email)` |
| Find many | `TaskModel.objects.filter(board_id=board_id)` |
| Create | `TaskModel.objects.create(**TaskModel.from_domain(domain).__dict__)` |
| Check exists | `TaskModel.objects.filter(email=email).exists()` |
| Select related | `TaskModel.objects.select_related("board").filter(board_id=board_id)` |
| Prefetch related | `BoardModel.objects.prefetch_related("columns__tasks").get(id=board_id)` |

## Model Conversion

- `model.to_domain()` -- convert Django model to domain object
- `ModelClass.from_domain(domain)` -- classmethod to convert domain to Django model

## Key Paths

- Storage: `backend/adapters/db/src/access/`
- Models: `backend/adapters/db/src/model/`
- Migrations: `backend/adapters/db/migrations/`
