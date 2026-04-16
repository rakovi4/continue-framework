# Test Review Patterns: Other Layers (Java/Spring)

Java/AssertJ code examples for selenium, email, scheduling, and security test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Selenium Anti-Pattern Examples

### BAD: isNotEmpty() in Selenium when test controls data
```java
// BAD:  assertThat(date.getText()).as("due date").isNotEmpty();
// GOOD: var task = taskStatements.getTask(apiSession);
//       String expectedDate = task.getDueDate().format(DATE_FORMATTER);
//       assertThat(date.getText()).as("due date").isEqualTo(expectedDate);
```

### BAD: In-app URL navigation in Selenium tests
```java
// BAD: navigates directly via URL
public void navigateToCreateTaskWizard(String appUrl) {
    browser.navigateTo(appUrl + "/create");
}
// GOOD: navigate through UI clicks
public void navigateToCreateTaskWizard(String appUrl) {
    browser.navigateTo(appUrl);  // app root only
    browser.findElement(NEW_TASK_BUTTON).click();
}
```

### BAD: UnsupportedOperationException in Statements
```java
// BAD: stubbed like production adapter
public void assertErrorBannerDisplayed() {
    throw new UnsupportedOperationException();
}
// GOOD: write real implementation in RED
public void assertErrorBannerDisplayed() {
    WebElement banner = browser.findElement(ERROR_BANNER);
    assertThat(banner.isDisplayed()).as("error banner is displayed").isTrue();
    assertThat(banner.getText()).as("error banner contains message").contains("Something went wrong");
}
```

### BAD: Selenium assertion shallower than spec
```java
// BAD: only checks count
public void assertTaskCardsDisplayed() {
    List<WebElement> cards = browser.findElements(TASK_CARD);
    assertThat(cards).as("task cards are displayed").hasSizeGreaterThanOrEqualTo(1);
}
// GOOD: verify sub-elements inside each card
public void assertTaskCardsDisplayed() {
    List<WebElement> cards = browser.findElements(TASK_CARD);
    assertThat(cards).as("task cards are displayed").hasSizeGreaterThanOrEqualTo(1);
    for (WebElement card : cards) {
        assertThat(card.findElement(TASK_TITLE).isDisplayed()).as("card contains title").isTrue();
        assertThat(card.findElement(TASK_TITLE).getText()).as("title is not empty").isNotEmpty();
        assertThat(card.findElement(TASK_STATUS).isDisplayed()).as("card contains status badge").isTrue();
        assertThat(card.findElement(TASK_ASSIGNEE).isDisplayed()).as("card contains assignee").isTrue();
        assertThat(card.findElement(TASK_PRIORITY).isDisplayed()).as("card contains priority").isTrue();
        assertThat(card.findElement(TASK_PRIORITY).getText()).as("priority is not empty").isNotEmpty();
    }
}
```
