# Usecase Implementation Template -- C#/ASP.NET Core

> Universal rules: `.claude/templates/tdd/green-usecase.md`

## Tech-Specific Details

- Not-implemented marker: `throw new NotImplementedException()`
- Domain path: `backend/Domain/`
- Adapter interfaces path: `backend/Usecase/Adapters/`

## Reference (read before generating)

- Usecase example: `backend/Usecase/{Feature}/{Feature}Usecase.cs`
- Adapter interface: `backend/Usecase/Adapters/`
- Fake implementation: `backend/Usecase.Tests/Fake/{Feature}/Fake{Feature}Storage.cs`

## Key Paths

- Production: `backend/Usecase/{Feature}/`
- Tests: `backend/Usecase.Tests/{Feature}/`
- Fakes: `backend/Usecase.Tests/Fake/`
