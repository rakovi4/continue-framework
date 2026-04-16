# Acceptance Test Template -- Python/Django

> Universal structure and rules: `.claude/templates/tdd/red-acceptance.md`

## Framework Rules

- Inherits from `AbstractBackendTest` (backend) or `AbstractUiTest` (frontend)
- `@pytest.mark.skip(reason="TDD Red Phase - Not yet implemented")` on test class
- Not-implemented marker in Statements: `raise NotImplementedError()`
- Add class-level docstring with Gherkin-style scenario
- Statements are plain classes instantiated in `conftest.py` fixtures

## Test Types

| Type | Base Class | Marker |
|------|------------|--------|
| Backend API | `AbstractBackendTest` | `@pytest.mark.backend` |
| Frontend UI | `AbstractUiTest` | `@pytest.mark.frontend` |

## Reference Paths

- Test example: `acceptance/tests/backend/{feature}/test_{feature}_acceptance.py`
- Base class: `acceptance/tests/backend/abstract_backend_test.py`
- Statements example: `acceptance/statements/{feature}_statements.py`
- Client: `acceptance/clients/application/application_client.py`
- TestData: `acceptance/statements/test_data.py`

## Key Paths

- Backend tests: `acceptance/tests/backend/`
- Statements: `acceptance/statements/`
- Client: `acceptance/clients/application/`
- DTOs: `acceptance/clients/application/dto/`
