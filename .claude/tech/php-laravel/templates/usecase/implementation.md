# Usecase Implementation Template -- PHP/Laravel

> Universal rules: `.claude/templates/tdd/green-usecase.md`

## Tech-Specific Details

- Not-implemented marker: `throw new \RuntimeException('Not implemented')`
- Domain path: `backend/domain/src/`
- Adapter interfaces path: `backend/usecase/src/Adapters/`

## Reference (read before generating)

- Usecase example: `backend/usecase/src/{Feature}/{Feature}Usecase.php`
- Adapter interface: `backend/usecase/src/Adapters/`
- Fake implementation: `backend/usecase/tests/Fake/{Feature}/Fake{Feature}Storage.php`

## Key Paths

- Production: `backend/usecase/src/{Feature}/`
- Tests: `backend/usecase/tests/{Feature}/`
- Fakes: `backend/usecase/tests/Fake/`
