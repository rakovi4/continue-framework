# Database Storage Implementation Template -- C#/ASP.NET Core

## Rules

- Replace stub implementation with actual logic using EF Core
- Map between EF Core entity and domain objects using conversion methods
- Use `DbContext` with `DbSet<T>` for data access

## Reference (read before generating)

- Storage example: `backend/Adapters/Db/Access/{Feature}/{Feature}Storage.cs`
- Entity example: `backend/Adapters/Db/Model/{Feature}/{Feature}Entity.cs`
- Migration directory: `backend/Adapters/Db/Migrations/`

## EF Core Query Methods

| Operation | Code |
|-----------|------|
| Find by field | `await context.Tasks.FirstOrDefaultAsync(t => t.Email == email)` |
| Find many | `await context.Tasks.Where(t => t.BoardId == boardId).ToListAsync()` |
| Create | `context.Tasks.Add(TaskEntity.FromDomain(domain)); await context.SaveChangesAsync()` |
| Check exists | `await context.Tasks.AnyAsync(t => t.Email == email)` |
| Include related | `await context.Tasks.Include(t => t.Board).Where(t => t.BoardId == boardId).ToListAsync()` |
| ThenInclude | `await context.Boards.Include(b => b.Columns).ThenInclude(c => c.Tasks).FirstAsync(b => b.Id == boardId)` |

## Entity Conversion

- `entity.ToDomain()` — convert EF Core entity to domain object
- `EntityClass.FromDomain(domain)` — static method to convert domain to EF Core entity

## Key Paths

- Storage: `backend/Adapters/Db/Access/`
- Entities: `backend/Adapters/Db/Model/`
- Migrations: `backend/Adapters/Db/Migrations/`
- DbContext: `backend/Adapters/Db/AppDbContext.cs`
