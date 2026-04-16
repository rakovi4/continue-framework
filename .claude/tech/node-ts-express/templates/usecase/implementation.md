# Usecase Implementation Template -- Node/TS/Express

> Universal rules: `.claude/templates/tdd/green-usecase.md`

## Tech-Specific Details

- Not-implemented marker: `throw new Error("Not implemented")`
- Domain path: `backend/domain/src/`
- Adapter interfaces path: `backend/usecase/src/adapters/`

## Reference (read before generating)

- Usecase example: `backend/usecase/src/{feature}/{Feature}UseCase.ts`
- Adapter interface: `backend/usecase/src/adapters/`
- Fake implementation: `backend/usecase/src/__tests__/fake/{feature}/Fake{Feature}Storage.ts`

## Key Paths

- Production: `backend/usecase/src/{feature}/`
- Tests: `backend/usecase/src/__tests__/{feature}/`
- Fakes: `backend/usecase/src/__tests__/fake/`
