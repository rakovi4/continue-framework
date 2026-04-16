# Usecase Implementation Template -- Java/Spring

> Universal rules: `.claude/templates/tdd/green-usecase.md`

## Tech-Specific Details

- Not-implemented marker: `throw new UnsupportedOperationException("Not implemented yet")`
- Domain path: `backend/domain/src/main/java/com/example/domain/`
- Adapter interfaces path: `backend/usecase/src/main/java/com/example/usecase/adapters/`

## Reference (read before generating)

- Usecase example: `backend/usecase/src/main/java/com/example/usecase/task/create/CreateTask.java`
- Adapter interface: `backend/usecase/src/main/java/com/example/usecase/adapters/`
- Fake implementation: `backend/usecase/src/test/java/com/example/usecase/fake/task/FakeTaskStorage.java`

## Key Paths

- Production: `backend/usecase/src/main/java/com/example/usecase/{feature}/`
- Tests: `backend/usecase/src/test/java/com/example/usecase/{feature}/`
- Fakes: `backend/usecase/src/test/java/com/example/usecase/fake/`
