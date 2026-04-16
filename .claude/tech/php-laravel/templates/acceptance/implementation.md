# Acceptance Test Implementation (Green Phase) -- PHP/Laravel

> Universal workflow: `.claude/templates/tdd/green-acceptance.md`

## Tech-Specific Details

- **Disable marker**: `$this->markTestSkipped(...)` -- remove to enable, re-add on failure
- **Test target**: `{TestClassName}` (class name for PHPUnit `--filter`)
- **Error terminology**: "exception handler" (Laravel `Handler.php`)
