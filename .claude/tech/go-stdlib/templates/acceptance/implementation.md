# Acceptance Test Implementation (Green Phase) -- Go/stdlib

> Universal workflow: `.claude/templates/tdd/green-acceptance.md`

## Tech-Specific Details

- **Disable marker**: `t.Skip(...)` — remove to enable, re-add on failure
- **Test target**: `TestFunctionName` (function name for `-run` filter)
- **Error terminology**: "error-handling middleware" (chi middleware)
