# Selenium Browser Testing Conventions

Tech binding for `frontend-rules.md` Selenium section. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## 2-Tier DSL Architecture

1. **Test Class** -- extends `AbstractUiTest` (provides `webDriver`, `appUrl`, `wait`). Reads like English.
2. **Statements Class** -- encapsulates locators, navigation, and assertions.

## Test Class Rules

- Delegates ALL WebDriver interaction to Statements class.
- NO `findElement`, `By.cssSelector`, or assertions in test class.
- NO infrastructure calls -- delegate to backend Statements.
- Inject each focused Statements directly -- no middleman forwarding.

## Statements Rules

- Locators: `private static final By` constants at top of class.
- Methods: `navigate*`, `enter*`, `click*`, `assert*`.
- Page Statements own browser interactions only.
- `driver.get()` only for app root (`appUrl`) and external entry points.
- ALL methods fully functional in RED -- real locators, waits, assertions.

## Element Locators

- Primary: `By.cssSelector("[data-testid='...']")`.
- Fallback: `By.id("...")` if natural id exists.
- Last resort: `findElementByText("...")`.
- FORBIDDEN: `By.className`, `By.tagName`, raw CSS class/tag selectors.

## Component data-testid Attributes

Components MUST include `data-testid`. See `templates/selenium-test.md` for markup examples.

## Assertion Detail Level

Assertions must match spec detail level -- verify sub-elements within each card (find child `task-title`, `task-status`, etc., assert displayed + non-empty).

## Prerequisites

Backend running, frontend running, all logic + API tests pass.
