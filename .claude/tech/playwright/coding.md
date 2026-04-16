# Playwright Browser Testing Conventions

Tech binding for `frontend-rules.md` Selenium section. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## 2-Tier DSL Architecture

1. **Test Class** -- receives `page` and `appUrl` from test fixture. Reads like English.
2. **Statements Class** -- encapsulates locators, navigation, and assertions.

## Test Class Rules

- Delegates ALL Playwright interaction to Statements class.
- NO `page.locator`, `page.getByTestId`, or `expect` calls in test class.
- NO infrastructure calls -- delegate to backend Statements.

## Statements Rules

- Locators: built via `page.getByTestId('...')` inside methods (lazy, no static constants needed).
- Methods: `navigate*`, `enter*`, `click*`, `assert*`.
- Page Statements own browser interactions only.
- `page.goto()` only for app root (`appUrl`) and external entry points.

## Element Locators

- Primary: `page.getByTestId('...')`.
- Fallback: `page.getByRole(...)` if natural ARIA role exists.
- Last resort: `page.getByText('...')`.
- FORBIDDEN: `page.locator('.class')`, `page.locator('div')`, CSS class/tag selectors.

## Component data-testid Attributes

Components MUST include `data-testid`. See `templates/playwright-test.md` for markup examples.

## Prerequisites

Backend running, frontend running, all logic + API tests pass.
