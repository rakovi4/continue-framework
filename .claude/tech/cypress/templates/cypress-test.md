# Frontend Cypress Test Template

Rules: see `coding.md` and `tdd.md` in the cypress tech profile.

## Test Class

Location: `acceptance/cypress/e2e/{feature}/`

```typescript
import { CreateTaskPageStatements } from '../../statements/frontend/create-task-page.statements';

describe('Create Task Page', () => {
    const createTaskPage = new CreateTaskPageStatements();

    it.skip('UI Test Scenario 1: Create Task Form Initial State — ' +
        'Given the user navigates to the create task page, ' +
        'Then the task form is displayed, ' +
        'And the title field is focused automatically, ' +
        'And all required fields are marked clearly, ' +
        'And the description field is marked as optional, ' +
        'And the create task button is enabled, ' +
        'And the back to board link is visible', () => {

        createTaskPage.navigateToCreateTaskPage();

        createTaskPage.assertFormIsDisplayed();
        createTaskPage.assertTitleFieldIsFocused();
        createTaskPage.assertRequiredFieldsAreDisplayed();
        createTaskPage.assertDescriptionIsOptional();
        createTaskPage.assertSubmitButtonIsEnabled();
        createTaskPage.assertBackToBoardLinkIsVisible();
    });
});
```

## Statements Class

Location: `acceptance/cypress/statements/frontend/`

```typescript
const TASK_FORM = '[data-testid="task-form"]';
const TITLE_INPUT = '[data-testid="title-input"]';
const SUBMIT_BUTTON = '[data-testid="submit-button"]';

export class CreateTaskPageStatements {

    navigateToCreateTaskPage(): void {
        cy.visit('/');
        cy.get('[data-testid="create-task-link"]').click();
    }

    assertFormIsDisplayed(): void {
        cy.get(TASK_FORM).should('be.visible');
    }

    assertSubmitButtonIsEnabled(): void {
        cy.get(SUBMIT_BUTTON).should('be.visible').and('be.enabled');
    }
}
```

## data-testid in Components

```tsx
<form data-testid="task-form">
<input data-testid="title-input" />
<button data-testid="submit-button">Create Task</button>
```
