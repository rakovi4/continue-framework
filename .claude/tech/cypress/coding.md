# Cypress Browser Testing Conventions

Tech binding for `frontend-rules.md` Selenium/Cypress section. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## 2-Tier DSL Architecture

1. **Test Class** -- `describe`/`it` blocks with Statements calls only.
2. **Statements Class** -- encapsulates selectors, navigation, and assertions.

## Test Class Rules

- Delegates ALL Cypress interaction to Statements class.
- NO `cy.get`, `cy.find`, or assertions in test class.
- NO infrastructure calls -- delegate to backend Statements.

## Statements Rules

- Selectors: `const` string constants at top of class/module.
- Methods: `navigate*`, `enter*`, `click*`, `assert*`.
- `cy.visit()` only for app root (`appUrl`) and external entry points.
- ALL methods fully functional in RED -- real selectors, assertions.

## Element Selectors

- Primary: `cy.get('[data-testid="..."]')`.
- Fallback: `cy.get('#id')` if natural id exists.
- Last resort: `cy.contains('text')`.
- FORBIDDEN: `cy.get('.className')`, `cy.get('tagName')`, raw CSS class/tag selectors.

## Component data-testid Attributes

Components MUST include `data-testid`. See `templates/cypress-test.md` for markup examples.

## Prerequisites

Backend running, frontend running, all logic + API tests pass.
