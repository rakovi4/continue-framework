# Test Review Patterns: Other Layers (PHP/Laravel)

PHP/PHPUnit code examples for selenium, email, scheduling, and security test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Selenium Anti-Pattern Examples

### BAD: isNotEmpty() in Selenium when test controls data
```php
// BAD:  $this->assertNotEmpty($date->getText(), 'due date');
// GOOD: $task = $this->taskStatements->getTask($apiSession);
//       $expectedDate = $task->dueDate->format('Y-m-d');
//       $this->assertEquals($expectedDate, $date->getText(), 'due date');
```

### BAD: In-app URL navigation in Selenium tests
```php
// BAD: navigates directly via URL
public function navigateToCreateTaskWizard(string $appUrl): void
{
    $this->driver->get("$appUrl/create");
}
// GOOD: navigate through UI clicks
public function navigateToCreateTaskWizard(string $appUrl): void
{
    $this->driver->get($appUrl);  // app root only
    $this->driver->findElement(WebDriverBy::cssSelector('[data-testid="new-task-button"]'))->click();
}
```

### BAD: RuntimeException in Statements
```php
// BAD: stubbed like production adapter
public function assertErrorBannerDisplayed(): void
{
    throw new \RuntimeException('Not implemented');
}
// GOOD: write real implementation in RED
public function assertErrorBannerDisplayed(): void
{
    $banner = $this->driver->findElement(WebDriverBy::cssSelector('[data-testid="error-banner"]'));
    $this->assertTrue($banner->isDisplayed(), 'error banner is displayed');
    $this->assertStringContainsString('Something went wrong', $banner->getText());
}
```

### BAD: Selenium assertion shallower than spec
```php
// BAD: only checks count
public function assertTaskCardsDisplayed(): void
{
    $cards = $this->driver->findElements(WebDriverBy::cssSelector('[data-testid="task-card"]'));
    $this->assertGreaterThanOrEqual(1, count($cards), 'task cards are displayed');
}
// GOOD: verify sub-elements inside each card
public function assertTaskCardsDisplayed(): void
{
    $cards = $this->driver->findElements(WebDriverBy::cssSelector('[data-testid="task-card"]'));
    $this->assertGreaterThanOrEqual(1, count($cards), 'task cards are displayed');
    foreach ($cards as $card) {
        $title = $card->findElement(WebDriverBy::cssSelector('[data-testid="task-title"]'));
        $this->assertTrue($title->isDisplayed(), 'card contains title');
        $this->assertNotEmpty($title->getText(), 'title is not empty');
        $status = $card->findElement(WebDriverBy::cssSelector('[data-testid="task-status"]'));
        $this->assertTrue($status->isDisplayed(), 'card contains status badge');
        $assignee = $card->findElement(WebDriverBy::cssSelector('[data-testid="task-assignee"]'));
        $this->assertTrue($assignee->isDisplayed(), 'card contains assignee');
        $priority = $card->findElement(WebDriverBy::cssSelector('[data-testid="task-priority"]'));
        $this->assertTrue($priority->isDisplayed(), 'card contains priority');
        $this->assertNotEmpty($priority->getText(), 'priority is not empty');
    }
}
```
