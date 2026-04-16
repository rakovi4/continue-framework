# Test Review Patterns: Other Layers (Python/Django)

Python/pytest code examples for selenium, email, scheduling, and security test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Selenium Anti-Pattern Examples

### BAD: `is not None` / truthy in Selenium when test controls data
```python
# BAD:
assert date.text, "due date"
# GOOD: capture from API setup, assert exact value
task = task_statements.get_task(api_session)
expected_date = task.due_date.strftime(DATE_FORMAT)
assert date.text == expected_date, "due date"
```

### BAD: In-app URL navigation in Selenium tests
```python
# BAD: navigates directly via URL
def navigate_to_create_task_wizard(self, app_url):
    self.driver.get(f"{app_url}/create")
# GOOD: navigate through UI clicks
def navigate_to_create_task_wizard(self, app_url):
    self.driver.get(app_url)  # app root only
    self.driver.find_element(By.CSS_SELECTOR, '[data-testid="new-task-button"]').click()
```

### BAD: NotImplementedError in Statements
```python
# BAD: stubbed like production adapter
def assert_error_banner_displayed(self):
    raise NotImplementedError()
# GOOD: write real implementation in RED
def assert_error_banner_displayed(self):
    banner = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="error-banner"]')
    assert banner.is_displayed(), "error banner is displayed"
    assert "Something went wrong" in banner.text, "error banner contains message"
```

### BAD: Selenium assertion shallower than spec
```python
# BAD: only checks count
def assert_task_cards_displayed(self):
    cards = self.driver.find_elements(By.CSS_SELECTOR, '[data-testid="task-card"]')
    assert len(cards) >= 1, "task cards are displayed"
# GOOD: verify sub-elements inside each card
def assert_task_cards_displayed(self):
    cards = self.driver.find_elements(By.CSS_SELECTOR, '[data-testid="task-card"]')
    assert len(cards) >= 1, "task cards are displayed"
    for card in cards:
        title = card.find_element(By.CSS_SELECTOR, '[data-testid="task-title"]')
        assert title.is_displayed(), "card contains title"
        assert title.text, "title is not empty"
        status = card.find_element(By.CSS_SELECTOR, '[data-testid="task-status"]')
        assert status.is_displayed(), "card contains status badge"
        assignee = card.find_element(By.CSS_SELECTOR, '[data-testid="task-assignee"]')
        assert assignee.is_displayed(), "card contains assignee"
        priority = card.find_element(By.CSS_SELECTOR, '[data-testid="task-priority"]')
        assert priority.is_displayed(), "card contains priority"
        assert priority.text, "priority is not empty"
```
