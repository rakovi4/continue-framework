# Acceptance Test Implementation (Green Phase) -- Python/Django

> Universal workflow: `.claude/templates/tdd/green-acceptance.md`

## Tech-Specific Details

- **Disable marker**: `@pytest.mark.skip` decorator -- remove to enable, re-add on failure
- **Test target**: `{test_file_name}` (file name for pytest `-k` filter)
- **Error terminology**: "exception handler middleware" (Django middleware)
