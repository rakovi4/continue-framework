# H2 Storage Implementation Template

## Rules

- Replace stub implementation with actual logic using JPA repository
- Map between entity and domain objects using existing conversion methods
- Use `@Transactional(propagation = Propagation.MANDATORY)` for write operations

## Reference (read before generating)

- Storage example: `backend/adapters/h2/src/main/java/com/example/h2/access/task/H2TaskStorage.java`
- Entity example: `backend/adapters/h2/src/main/java/com/example/h2/entity/task/TaskEntity.java`
- Repository example: `backend/adapters/h2/src/main/java/com/example/h2/repository/task/TaskJpaRepository.java`

## JPA Repository Query Methods

Spring Data JPA derives queries from method names. If repository doesn't have required method, add it:

| Method Name | Generated Query |
|------------|-----------------|
| `findByEmail(String)` | `WHERE email = ?1` |
| `findByEmailAndPassword(String, String)` | `WHERE email = ?1 AND password = ?2` |
| `existsByEmail(String)` | `SELECT COUNT(*) > 0 WHERE email = ?1` |

## Entity Conversion

- `Entity::toDomain` — convert entity to domain object
- `Entity.from(domain)` or `new Entity(domain)` — convert domain to entity

## Key Paths

- Storage: `backend/adapters/h2/src/main/java/com/example/h2/access/`
- Entities: `backend/adapters/h2/src/main/java/com/example/h2/entity/`
- Repositories: `backend/adapters/h2/src/main/java/com/example/h2/repository/`
