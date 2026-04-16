# Usecase Test Template -- Python/Django

> Universal rules: `.claude/templates/tdd/red-usecase.md`

## 3-Tier Locations

| Layer | Location |
|-------|----------|
| Test Class | `{feature}/test_{feature}_usecase.py` |
| Statements | `statements/{feature}_statements.py` |
| Scope | `scope/{feature}_request_scope.py` |

## Tech-Specific Rules

- `@pytest.mark.skip(reason="RED: ...")` on test class
- Use `class TestFeatureName:` with `test_should_{expected_behavior}` methods
- Add class-level docstring with Gherkin-style scenario text
- Not-implemented marker: `raise NotImplementedError()`
- Empty values: `None` for optional fields, `[]` for collections

## Reference (read before generating)

- Test class: `backend/usecase/tests/{feature}/test_{feature}_usecase.py`
- Statements: `backend/usecase/tests/statements/{feature}_statements.py`
- Scope: `backend/usecase/tests/scope/{feature}_request_scope.py`
- Base setup: `backend/usecase/tests/conftest.py`
- TestData: `backend/usecase/tests/scope/test_data.py`
- Fake example: `backend/usecase/tests/fake/{feature}/fake_{feature}_storage.py`

## Update conftest.py

Add new use-case and statements fixtures to `conftest.py` if needed (follow the existing sections).

## Key Paths

- Tests: `backend/usecase/tests/{feature}/`
- Production: `backend/usecase/src/{feature}/`
- Base setup: `backend/usecase/tests/conftest.py`
- Statements: `backend/usecase/tests/statements/`
- Scopes: `backend/usecase/tests/scope/`
- Fakes: `backend/usecase/tests/fake/`
