# Usecase Implementation Template -- C++/CMake

> Universal rules: `.claude/templates/tdd/green-usecase.md`

## Tech-Specific Details

- Not-implemented marker: `throw std::logic_error("Not implemented")`
- Domain path: `backend/domain/include/domain/` and `backend/domain/src/`
- Adapter interfaces path: `backend/usecase/include/usecase/adapters/`

## Reference (read before generating)

- Usecase example: `backend/usecase/src/task/create/create_task.cpp`
- Usecase header: `backend/usecase/include/usecase/task/create/create_task.h`
- Adapter interface: `backend/usecase/include/usecase/adapters/`
- Fake implementation: `backend/usecase/tests/fake/task/fake_task_storage.h`

## Key Paths

- Production headers: `backend/usecase/include/usecase/{feature}/`
- Production sources: `backend/usecase/src/{feature}/`
- Tests: `backend/usecase/tests/{feature}/`
- Fakes: `backend/usecase/tests/fake/`
