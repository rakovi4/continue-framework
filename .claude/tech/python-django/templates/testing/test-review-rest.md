# Test Review Patterns: REST Adapter Layer (Python/Django)

Python/unittest.mock code examples for REST controller test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Python-Specific Rules (REST)

1. **Use descriptive assertion messages** -- add a second argument to `assert` for clear failure messages
2. **Use exact expected values in mock setups** -- `mock.assert_called_once_with(exact_request)` instead of `mock.assert_called()`. Add `__eq__` to request dataclasses. Strict mocks catch controller bugs that loose matchers miss
3. **No `unittest.mock.ANY` when exact value is known** -- if the expected argument is known, use the exact value in `assert_called_once_with()`

## Anti-Pattern Examples

### BAD: unittest.mock.ANY when exact value is known
```python
mock_usecase.execute.assert_called_once_with(USER_ID, unittest.mock.ANY)
# Should use exact expected request -- add __eq__ to request dataclass
mock_usecase.execute.assert_called_once_with(USER_ID, expected_request)
```

### BAD: mock.assert_called() without verifying arguments
```python
mock_usecase.execute.assert_called_once()
# Should verify exact arguments
mock_usecase.execute.assert_called_once_with(USER_ID, SomeRequest(period="monthly", active=True))
```

### BAD: Checking call_args manually instead of assert_called_once_with
```python
mock_usecase.execute(USER_ID, unittest.mock.ANY)
args, kwargs = mock_usecase.execute.call_args
assert args[1].field == "expected"
# Should just use exact match -- strict mock catches wrong arguments immediately
mock_usecase.execute.assert_called_once_with(USER_ID, expected_request)
```
