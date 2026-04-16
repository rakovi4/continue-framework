# Test Review Patterns: Other Layers (Node/TypeScript)

TypeScript/Vitest code examples for selenium, email, scheduling, and security test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Selenium Anti-Pattern Examples

### BAD: In-app URL navigation in Selenium tests
```typescript
// BAD: navigates directly via URL
async navigateToCreateTaskWizard(appUrl: string) {
    await this.driver.get(`${appUrl}/create`);
}
// GOOD: navigate through UI clicks
async navigateToCreateTaskWizard(appUrl: string) {
    await this.driver.get(appUrl);  // app root only
    await this.driver.findElement(By.css('[data-testid="new-task-button"]')).click();
}
```

### BAD: throw new Error("Not implemented") in Statements
```typescript
// BAD: stubbed like production adapter
async assertErrorBannerDisplayed() {
    throw new Error("Not implemented");
}
// GOOD: write real implementation in RED
async assertErrorBannerDisplayed() {
    const banner = await this.driver.findElement(By.css('[data-testid="error-banner"]'));
    expect(await banner.isDisplayed()).toBe(true);
    expect(await banner.getText()).toContain("Something went wrong");
}
```

### BAD: Selenium assertion shallower than spec
```typescript
// BAD: only checks count
async assertTaskCardsDisplayed() {
    const cards = await this.driver.findElements(By.css('[data-testid="task-card"]'));
    expect(cards.length).toBeGreaterThanOrEqual(1);
}
// GOOD: verify sub-elements inside each card
async assertTaskCardsDisplayed() {
    const cards = await this.driver.findElements(By.css('[data-testid="task-card"]'));
    expect(cards.length).toBeGreaterThanOrEqual(1);
    for (const card of cards) {
        const title = await card.findElement(By.css('[data-testid="task-title"]'));
        expect(await title.isDisplayed()).toBe(true);
        expect(await title.getText()).not.toEqual("");
        expect(await card.findElement(By.css('[data-testid="task-status"]')).isDisplayed()).toBe(true);
        expect(await card.findElement(By.css('[data-testid="task-assignee"]')).isDisplayed()).toBe(true);
        expect(await card.findElement(By.css('[data-testid="task-priority"]')).isDisplayed()).toBe(true);
    }
}
```

### BAD: toBeDefined() in Selenium when test controls data
```typescript
// BAD: expect(await date.getText()).toBeDefined();
// GOOD: compute expected text from API setup data
const task = await taskStatements.getTask(apiSession);
const expectedDate = formatDate(task.dueDate);
expect(await date.getText()).toEqual(expectedDate);
```
