# Playwright TDD Idioms

Tech binding for `tdd-rules.md`. Load alongside the universal rules.

## Test Disable Marker

- Playwright: `test.skip()` as first line inside the test body
- In RED: add `test.skip()` after validating prediction
- In GREEN: remove `test.skip()` (the only test modification allowed)

## Test Description

- Use `test.describe('...')` to group scenarios by feature/page
- Test name must include "UI Test Scenario N:" prefix referencing `02_UI_Tests.md`
- Test name must include full BDD gherkin from the test spec

## Statements Assertions (Playwright Built-in)

- Real `await expect(locator).toBeVisible()` calls, real `await expect(locator).toHaveText(...)` assertions
- Even when `toBeVisible()` is checked implicitly by Playwright auto-wait, the explicit assertion must stay
- Use descriptive assertion messages via `expect(locator, 'task form is displayed').toBeVisible()`

## Route Intercepts

- Backend Statements handle `page.route()` intercept configuration — never in page Statements
- Tests call backend Statements directly for all setup

## Statements Dependencies

- Statements are plain TypeScript classes — instantiated in test fixtures or `beforeEach`
- Constructor receives `page` (and `appUrl` when needed)
- Reuse `AuthenticationStatements`: `login(page)` for API session; `LoginPageStatements.loginAsTestUser(page, appUrl)` for browser login flow

## Test Verification

Run via: `Skill tool: skill="test-acceptance", args="frontend {TestClassName}"`
