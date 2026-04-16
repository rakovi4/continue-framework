# Acceptance Test Implementation (Green Phase) -- C++/CMake

> Universal workflow: `.claude/templates/tdd/green-acceptance.md`

## Tech-Specific Details

- **Disable marker**: `DISABLED_` prefix on test name — remove to enable, re-add on failure
- **Test target**: `--gtest_filter="*TestClassName*"` (class/test name for test runner filter)
- **Error terminology**: "gRPC interceptors" or centralized exception-to-status mapping in service base class
