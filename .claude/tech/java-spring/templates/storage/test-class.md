# H2 Storage Test Template

## Test Class Rules

- Implement `H2Test` interface
- Annotate with `@DataJpaTest`
- Autowire the storage class under test
- Use `@DisplayName` with Gherkin-style description

## H2-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| `return Optional.empty();` | `Expecting Optional to contain a value but was empty` |
| `return Collections.emptyList();` | `Expecting actual not to be empty` |

## Reference (read before generating)

- Test example: `backend/adapters/storage/src/test/java/com/example/storage/access/task/H2TaskStorageSaveTest.java`
- H2Test interface: `backend/adapters/storage/src/test/java/com/example/storage/H2Test.java`
- Storage example: `backend/adapters/storage/src/main/java/com/example/storage/access/user/H2TaskStorage.java`
- Entity example: `backend/adapters/storage/src/main/java/com/example/storage/entity/task/TaskEntity.java`

## Naming Convention

- Test class: `H2{Entity}Storage{Method}Test.java`
- Test method: `should{ExpectedBehavior}`

## Key Paths

- Tests: `backend/adapters/storage/src/test/java/com/example/storage/access/`
- Production: `backend/adapters/storage/src/main/java/com/example/storage/access/`
- Entities: `backend/adapters/storage/src/main/java/com/example/storage/entity/`
- Repositories: `backend/adapters/storage/src/main/java/com/example/storage/repository/`
