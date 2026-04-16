# Frontend Playwright Test Template

Rules: see `coding.md` and `tdd.md` in the playwright tech profile.

## Test Class

Location: `acceptance/tests/frontend/{feature}/`

```typescript
import { test, expect } from '@playwright/test';
import { CreateTaskPageStatements } from '../statements/create-task-page.statements';

test.describe('Create Task Page', () => {
    let createTaskPage: CreateTaskPageStatements;

    test.beforeEach(async ({ page }) => {
        createTaskPage = new CreateTaskPageStatements(page, process.env.APP_URL!);
    });

    test('UI Test Scenario 1: Create Task Form Initial State - Given the user navigates to the create task page, Then the task form is displayed...', async () => {
        test.skip(); // TDD Red Phase - task-form not found

        await createTaskPage.navigateToCreateTaskPage();

        await createTaskPage.assertFormIsDisplayed();
        await createTaskPage.assertTitleFieldIsFocused();
        await createTaskPage.assertRequiredFieldsAreDisplayed();
        await createTaskPage.assertDescriptionIsOptional();
        await createTaskPage.assertSubmitButtonIsEnabled();
        await createTaskPage.assertBackToBoardLinkIsVisible();
    });
});
```

## Statements Class

Location: `acceptance/tests/statements/frontend/`

```typescript
import { expect, type Page } from '@playwright/test';

export class CreateTaskPageStatements {
    constructor(
        private readonly page: Page,
        private readonly appUrl: string,
    ) {}

    async navigateToCreateTaskPage(): Promise<void> {
        await this.page.goto(this.appUrl);
        await this.page.getByTestId('create-task-link').click();
    }

    async assertFormIsDisplayed(): Promise<void> {
        await expect(
            this.page.getByTestId('task-form'),
            'task form is displayed',
        ).toBeVisible();
    }

    async assertSubmitButtonIsEnabled(): Promise<void> {
        await expect(
            this.page.getByTestId('submit-button'),
            'submit button is enabled',
        ).toBeEnabled();
    }
}
```

## data-testid in Components

```tsx
<form data-testid="task-form">
<input data-testid="title-input" />
<button data-testid="submit-button">Create Task</button>
```
