# HTTP Handler Implementation Template -- Go/stdlib

> Universal rules: `.claude/templates/tdd/green-rest.md`

## Tech-Specific Rules

- Constructor injection via struct fields set in `NewHandler(...)` factory function

## Reference (read before generating)

- Handler example: `backend/adapters/http/{feature}/{feature}_handler.go`
- Request DTO example: `backend/adapters/http/{feature}/dto/{feature}_request.go`
- Response DTO example: `backend/adapters/http/{feature}/dto/{feature}_response.go`

## Key Paths

- Handlers: `backend/adapters/http/{feature}/`
- DTOs: `backend/adapters/http/{feature}/dto/`
- Tests: `backend/adapters/http/{feature}/`
