# Controller Test Template -- Node/TS/Express

> Universal rules: `.claude/templates/tdd/red-rest.md`

## Tech-Specific Rules

- Use `supertest` with the Express app instance
- Mock use-case dependencies with `vi.fn()` / `jest.fn()`
- Create exactly ONE `it()` block, add `.skip`
- Use `describe("Feature: ...")` with Gherkin-style description
- Setup: `vi.mocked(usecase.execute).mockResolvedValue(...)`
- Execute: `supertest(app).get("/api/...").send(body)`
- Verify: `expect(response.body).toEqual(...)`

## Expected Response JSON

Create in `backend/adapters/rest/src/__tests__/fixtures/{feature}/` or inline as object literals for small responses.

## Reference (read before generating)

- Test example: `backend/adapters/rest/src/__tests__/controller/{feature}/{Feature}Controller.test.ts`
- Test setup: `backend/adapters/rest/src/__tests__/setup/RestTest.ts`
- Request DTO example: `backend/adapters/rest/src/dto/{feature}/{Feature}RequestDto.ts`
- JSON fixture example: `backend/adapters/rest/src/__tests__/fixtures/` (look for existing JSON files)

## Key Paths

- Tests: `backend/adapters/rest/src/__tests__/controller/`
- Production: `backend/adapters/rest/src/controller/`
- DTOs: `backend/adapters/rest/src/dto/`
- Fixtures: `backend/adapters/rest/src/__tests__/fixtures/`
