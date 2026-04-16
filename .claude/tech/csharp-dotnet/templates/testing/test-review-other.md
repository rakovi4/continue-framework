# Test Review Patterns: Other Layers (C#/ASP.NET Core)

C#/FluentAssertions code examples for selenium, email, scheduling, and security test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Selenium Anti-Pattern Examples

### BAD: NotBeNullOrEmpty in Selenium when test controls data
```csharp
// BAD:  date.Text.Should().NotBeNullOrEmpty("due date");
// GOOD: var task = taskStatements.GetTask(apiSession);
//       var expectedDate = task.DueDate.ToString(DATE_FORMAT);
//       date.Text.Should().Be(expectedDate, "due date");
```

### BAD: In-app URL navigation in Selenium tests
```csharp
// BAD: navigates directly via URL
public void NavigateToCreateTaskWizard(string appUrl)
{
    driver.Navigate().GoToUrl(appUrl + "/create");
}
// GOOD: navigate through UI clicks
public void NavigateToCreateTaskWizard(string appUrl)
{
    driver.Navigate().GoToUrl(appUrl);  // app root only
    driver.FindElement(By.CssSelector("[data-testid='new-task-button']")).Click();
}
```

### BAD: NotImplementedException in Statements
```csharp
// BAD: stubbed like production adapter
public void AssertErrorBannerDisplayed()
{
    throw new NotImplementedException();
}
// GOOD: write real implementation in RED
public void AssertErrorBannerDisplayed()
{
    var banner = driver.FindElement(By.CssSelector("[data-testid='error-banner']"));
    banner.Displayed.Should().BeTrue("error banner is displayed");
    banner.Text.Should().Contain("Something went wrong", "error banner contains message");
}
```

### BAD: Selenium assertion shallower than spec
```csharp
// BAD: only checks count
public void AssertTaskCardsDisplayed()
{
    var cards = driver.FindElements(By.CssSelector("[data-testid='task-card']"));
    cards.Should().HaveCountGreaterOrEqualTo(1, "task cards are displayed");
}
// GOOD: verify sub-elements inside each card
public void AssertTaskCardsDisplayed()
{
    var cards = driver.FindElements(By.CssSelector("[data-testid='task-card']"));
    cards.Should().HaveCountGreaterOrEqualTo(1, "task cards are displayed");
    foreach (var card in cards)
    {
        card.FindElement(By.CssSelector("[data-testid='task-title']")).Displayed.Should().BeTrue("card contains title");
        card.FindElement(By.CssSelector("[data-testid='task-title']")).Text.Should().NotBeNullOrEmpty("title is not empty");
        card.FindElement(By.CssSelector("[data-testid='task-status']")).Displayed.Should().BeTrue("card contains status badge");
        card.FindElement(By.CssSelector("[data-testid='task-assignee']")).Displayed.Should().BeTrue("card contains assignee");
        card.FindElement(By.CssSelector("[data-testid='task-priority']")).Displayed.Should().BeTrue("card contains priority");
        card.FindElement(By.CssSelector("[data-testid='task-priority']")).Text.Should().NotBeNullOrEmpty("priority is not empty");
    }
}
```
