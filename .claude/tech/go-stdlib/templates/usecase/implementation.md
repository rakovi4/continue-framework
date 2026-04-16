# Usecase Implementation Template -- Go/stdlib

> Universal rules: `.claude/templates/tdd/green-usecase.md`

## Tech-Specific Details

- Not-implemented marker: `panic("not implemented")`
- Domain path: `backend/domain/`
- Adapter interfaces path: `backend/usecase/port/`

## Reference (read before generating)

- Usecase example: `backend/usecase/{feature}/{feature}_usecase.go`
- Adapter interface: `backend/usecase/port/`
- Fake implementation: `backend/usecase/testutil/fake/{feature}/fake_{feature}_storage.go`

## Key Paths

- Production: `backend/usecase/{feature}/`
- Tests: `backend/usecase/{feature}/`
- Fakes: `backend/usecase/testutil/fake/`
