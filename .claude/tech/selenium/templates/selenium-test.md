# Frontend Selenium Test Template

Rules: see `coding.md` and `tdd.md` in the selenium tech profile.

## Test Class

Location: `acceptance/src/test/java/app/acceptance/tests/frontend/{feature}/`

```java
public class CreateTaskPageTest extends AbstractUiTest {

    private final CreateTaskPageStatements createTaskPage = new CreateTaskPageStatements();

    @Disabled("TDD Red Phase - NoSuchElementException: task-form not found")
    @Test
    @Description("""
        UI Test Scenario 1: Create Task Form Initial State
        Given the user navigates to the create task page
        Then the task form is displayed
        And the title field is focused automatically
        And all required fields are marked clearly
        And the description field is marked as optional
        And the create task button is enabled
        And the back to board link is visible
        """)
    void should_display_create_task_form_initial_state() {
        createTaskPage.navigateToCreateTaskPage(webDriver, appUrl);

        createTaskPage.assertFormIsDisplayed(webDriver);
        createTaskPage.assertTitleFieldIsFocused(webDriver);
        createTaskPage.assertRequiredFieldsAreDisplayed(webDriver);
        createTaskPage.assertDescriptionIsOptional(webDriver);
        createTaskPage.assertSubmitButtonIsEnabled(webDriver);
        createTaskPage.assertBackToBoardLinkIsVisible(webDriver);
    }
}
```

## Statements Class

Location: `acceptance/src/test/java/app/acceptance/statements/frontend/`

```java
public class CreateTaskPageStatements {

    private static final By TASK_FORM = By.cssSelector("[data-testid='task-form']");
    private static final By TITLE_INPUT = By.cssSelector("[data-testid='title-input']");
    private static final By SUBMIT_BUTTON = By.cssSelector("[data-testid='submit-button']");

    public void navigateToCreateTaskPage(WebDriver driver, String appUrl) {
        driver.get(appUrl);
        driver.findElement(CREATE_TASK_LINK).click();
    }

    public void assertFormIsDisplayed(WebDriver driver) {
        WebElement form = driver.findElement(TASK_FORM);
        assertThat(form.isDisplayed()).as("task form is displayed").isTrue();
    }

    public void assertSubmitButtonIsEnabled(WebDriver driver) {
        WebElement button = driver.findElement(SUBMIT_BUTTON);
        assertThat(button.isEnabled()).as("submit button is enabled").isTrue();
    }
}
```

## data-testid in React Components

```tsx
<form data-testid="task-form">
<input data-testid="title-input" />
<button data-testid="submit-button">Create Task</button>
```
