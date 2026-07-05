# Database Storage Implementation Template

## Rules

- Replace stub implementation with actual logic using ORM (Prisma/TypeORM/Knex)
- Map between entity and domain objects using conversion methods
- Wrap write operations in transactions when needed

## Reference (read before generating)

- Storage example: `backend/adapters/db/src/access/{feature}/{Feature}Storage.ts`
- Entity example: `backend/adapters/db/src/entity/{feature}/{Feature}Entity.ts`
- ORM config: `backend/adapters/db/src/config/`

## ORM Query Examples (Prisma)

| Operation | Code |
|-----------|------|
| Find by field | `prisma.task.findUnique({ where: { email } })` |
| Find many | `prisma.task.findMany({ where: { boardId } })` |
| Create | `prisma.task.create({ data: TaskEntity.from(domain) })` |
| Check exists | `prisma.task.count({ where: { email } }) > 0` |

## ORM Query Examples (TypeORM)

| Operation | Code |
|-----------|------|
| Find by field | `repository.findOne({ where: { email } })` |
| Find many | `repository.find({ where: { boardId } })` |
| Create | `repository.save(TaskEntity.from(domain))` |
| Check exists | `repository.count({ where: { email } }) > 0` |

## Key Paths

- Storage: `backend/adapters/db/src/access/`
- Entities: `backend/adapters/db/src/entity/`
- Migrations: `backend/adapters/db/src/migrations/` or `prisma/migrations/`
