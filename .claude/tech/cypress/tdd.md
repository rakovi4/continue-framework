# Cypress TDD Idioms

Tech binding for `tdd-rules.md`. Load alongside the universal rules.

## Test Disable Marker

- Cypress: `it.skip()` on test cases
- In RED: add `.skip` after validating prediction
- In GREEN: remove `.skip` (the only test modification allowed)

## Test Description

- Use the `it('...')` description string to document the scenario
- Description MUST include "UI Test Scenario N:" prefix referencing `02_UI_Tests.md`
- Description MUST include full BDD gherkin from the test spec

## Statements Assertions (Chai)

- Cypress auto-retries assertions — use `should('be.visible')`, `should('have.text', '...')`, `should('be.enabled')`
- Even when `cy.get()` implicitly waits for existence, explicit `.should('be.visible')` assertions must stay
- Use descriptive assertion chains for clarity

## cy.intercept Stubs

- Backend Statements handle `cy.intercept()` stub configuration — never in page Statements
- Tests call backend Statements directly for all setup

## Statements Dependencies

- Statements are plain classes or modules — instantiate directly or import functions
- Reuse `AuthenticationStatements`: API login for session setup; `LoginPageStatements.loginAsTestUser(appUrl)` for browser login flow

## Test Verification

```
Skill tool: skill="test-acceptance", args="frontend {TestFileName}"
```
