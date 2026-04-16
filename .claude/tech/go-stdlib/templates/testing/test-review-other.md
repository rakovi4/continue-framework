# Test Review Patterns: Other Layers (Go/stdlib)

Go/testify code examples for selenium, email, scheduling, and security test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Selenium Anti-Pattern Examples

### BAD: assert.NotEmpty in Selenium when test controls data
```go
// BAD:
assert.NotEmpty(t, dateElement.Text(), "due date")

// GOOD: capture from API, assert exact
task := taskStatements.GetTask(apiSession)
expectedDate := task.DueDate.Format("2006-01-02")
assert.Equal(t, expectedDate, dateElement.Text(), "due date")
```

### BAD: In-app URL navigation in Selenium tests
```go
// BAD: navigates directly via URL
func (s *TaskStatements) NavigateToCreateTaskWizard(appURL string) {
    s.browser.NavigateTo(appURL + "/create")
}

// GOOD: navigate through UI clicks
func (s *TaskStatements) NavigateToCreateTaskWizard(appURL string) {
    s.browser.NavigateTo(appURL) // app root only
    s.browser.FindElement(newTaskButton).Click()
}
```

### BAD: panic("not implemented") in Statements
```go
// BAD: stubbed like production adapter
func (s *TaskStatements) AssertErrorBannerDisplayed() {
    panic("not implemented")
}

// GOOD: write real implementation in RED
func (s *TaskStatements) AssertErrorBannerDisplayed() {
    banner := s.browser.FindElement(errorBanner)
    assert.True(s.t, banner.IsDisplayed(), "error banner is displayed")
    assert.Contains(s.t, banner.Text(), "Something went wrong", "error banner contains message")
}
```

### BAD: Selenium assertion shallower than spec
```go
// BAD: only checks count
func (s *TaskStatements) AssertTaskCardsDisplayed() {
    cards := s.browser.FindElements(taskCard)
    assert.GreaterOrEqual(s.t, len(cards), 1, "task cards are displayed")
}

// GOOD: verify sub-elements inside each card
func (s *TaskStatements) AssertTaskCardsDisplayed() {
    cards := s.browser.FindElements(taskCard)
    assert.GreaterOrEqual(s.t, len(cards), 1, "task cards are displayed")
    for _, card := range cards {
        title := card.FindElement(taskTitle)
        assert.True(s.t, title.IsDisplayed(), "card contains title")
        assert.NotEmpty(s.t, title.Text(), "title is not empty")
        assert.True(s.t, card.FindElement(taskStatus).IsDisplayed(), "card contains status badge")
        assert.True(s.t, card.FindElement(taskAssignee).IsDisplayed(), "card contains assignee")
        priority := card.FindElement(taskPriority)
        assert.True(s.t, priority.IsDisplayed(), "card contains priority")
        assert.NotEmpty(s.t, priority.Text(), "priority is not empty")
    }
}
```
