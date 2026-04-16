# Controller Test Template -- Python/Django

> Universal rules: `.claude/templates/tdd/red-rest.md`

## Tech-Specific Rules

- Use Django `TestCase` with `APIClient` (DRF) or `Client` (plain Django)
- Mock use-case dependencies with `unittest.mock.patch` or `unittest.mock.Mock`
- Create exactly ONE test method, add `@pytest.mark.skip`
- Use class-level docstring with Gherkin-style description
- Setup: `mock_usecase.execute.return_value = ...`
- Execute: `self.client.get("/api/...")` or `self.client.post("/api/...", data, format="json")`
- Verify: `assert response.json() == expected`

## Expected Response JSON

Create in `backend/adapters/rest/tests/fixtures/{feature}/` or inline as dict literals for small responses.

## Reference (read before generating)

- Test example: `backend/adapters/rest/tests/controller/{feature}/test_{feature}_controller.py`
- Test setup: `backend/adapters/rest/tests/conftest.py`
- Request DTO example: `backend/adapters/rest/src/dto/{feature}/{feature}_request_dto.py`
- JSON fixture example: `backend/adapters/rest/tests/fixtures/` (look for existing JSON files)

## Key Paths

- Tests: `backend/adapters/rest/tests/controller/`
- Production: `backend/adapters/rest/src/controller/`
- DTOs: `backend/adapters/rest/src/dto/`
- Fixtures: `backend/adapters/rest/tests/fixtures/`
