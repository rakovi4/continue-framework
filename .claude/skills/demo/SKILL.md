---
name: demo
description: Run a Selenium test in visible (non-headless) mode with slowdown so the user can watch it. Use when user wants to demo or visually watch a Selenium test or mentions /demo command.
---

# /demo - Run Selenium Test in Visible Slow-Motion Mode

## Usage
```
/demo should_display_board_with_columns
/demo CreateTaskPageTest.should_display_create_task_form
/demo CreateTaskPageTest                          # Run all tests in class
/demo                                             # Run all frontend Selenium tests
```

## What It Does

Temporarily modifies Selenium configuration to run browser tests visibly with delays, so the user can watch the test execute in real time. All changes are reverted after the test completes (even on failure).

## Setup

Read `ProductSpecification/technology.md` for:
- `tech-profile` block → resolve `backend` concern to `.claude/tech/{backend}/templates/acceptance/` for file paths and language conventions
- **Acceptance test command** from Conventions table

Read `.claude/tech/{backend}/templates/acceptance/` to find the UI test base class and Browser statements class paths and conventions.

## Workflow

### 1. Load Port Configuration

Read ports from `infrastructure/.env`:
```bash
source infrastructure/.env
```

### 2. Apply Demo Changes

Locate the UI test base class and Browser statements class using tech profile template conventions.

**UI test base class:**
- Set close-browser-after-tests flag to false
- Comment out headless mode configuration

**Browser statements class:**
- Add a demo delay constant (1200ms)
- Add a demo delay method
- Insert demo delay calls at the start of: navigation, find-element, find-elements methods

### 3. Ensure Clean Environment

- Kill any existing backend process: `infrastructure/scripts/stop-backend.sh`
- Clear test email inbox via infrastructure HTTP API
- Start backend fresh: `infrastructure/scripts/run-backend.sh` (background)
- Wait for backend to be UP: poll health endpoint (read from tech profile)
- Verify frontend is running (start with `/run-frontend` if not)

### 4. Run the Test

Resolve the argument to a test filter using the acceptance test command pattern from Conventions table.

| Argument | Filter |
|----------|--------|
| `should_method_name` | Filter to `*.ClassName.should_method_name` (search test files to resolve class) |
| `ClassName.should_method_name` | Filter to `*.ClassName.should_method_name` |
| `ClassName` | Filter to `*.ClassName` |
| *(none)* | Run all frontend acceptance tests |

Use a generous timeout (180s) since delays add up.

### 5. Revert All Changes (ALWAYS)

After the test finishes (pass or fail), revert both files to their original state — undo all changes from step 2.

### 6. Report Result

Report whether the test passed or failed. If it failed, include the error output.

## Rules

- ALWAYS revert changes, even if the test fails or times out
- Do NOT commit any demo changes
- Do NOT leave the backend process running after — it was only restarted for a clean DB
- The working tree must be clean after `/demo` completes
