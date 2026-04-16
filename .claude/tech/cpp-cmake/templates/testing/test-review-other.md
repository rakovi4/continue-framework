# Test Review Patterns: Other Layers (C++/Google Test)

C++/Google Test code examples for selenium, email, scheduling, and security test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Selenium Anti-Pattern Examples

### BAD: !empty() in Selenium when test controls data
```cpp
// BAD:
EXPECT_FALSE(date.get_text().empty()) << "due date";
// GOOD: capture from API setup, assert exact value
auto task = task_statements.get_task(api_session);
auto expected_date = format_date(task.due_date());
EXPECT_EQ(date.get_text(), expected_date) << "due date";
```

### BAD: In-app URL navigation in Selenium tests
```cpp
// BAD: navigates directly via URL
void navigate_to_create_task_wizard(const std::string& app_url) {
    browser.navigate_to(app_url + "/create");
}
// GOOD: navigate through UI clicks
void navigate_to_create_task_wizard(const std::string& app_url) {
    browser.navigate_to(app_url);  // app root only
    browser.find_element(NEW_TASK_BUTTON).click();
}
```

### BAD: std::logic_error in Statements
```cpp
// BAD: stubbed like production adapter
void assert_error_banner_displayed() {
    throw std::logic_error("Not implemented");
}
// GOOD: write real implementation in RED
void assert_error_banner_displayed() {
    auto banner = browser.find_element(ERROR_BANNER);
    EXPECT_TRUE(banner.is_displayed()) << "error banner is displayed";
    EXPECT_THAT(banner.text(), HasSubstr("Something went wrong"));
}
```

### BAD: Selenium assertion shallower than spec
```cpp
// BAD: only checks count
void assert_task_cards_displayed() {
    auto cards = browser.find_elements(TASK_CARD);
    EXPECT_GE(cards.size(), 1) << "task cards are displayed";
}
// GOOD: verify sub-elements inside each card
void assert_task_cards_displayed() {
    auto cards = browser.find_elements(TASK_CARD);
    EXPECT_GE(cards.size(), 1) << "task cards are displayed";
    for (const auto& card : cards) {
        EXPECT_TRUE(card.find_element(TASK_TITLE).is_displayed()) << "card contains title";
        EXPECT_FALSE(card.find_element(TASK_TITLE).text().empty()) << "title is not empty";
        EXPECT_TRUE(card.find_element(TASK_STATUS).is_displayed()) << "card contains status badge";
        EXPECT_TRUE(card.find_element(TASK_ASSIGNEE).is_displayed()) << "card contains assignee";
        EXPECT_TRUE(card.find_element(TASK_PRIORITY).is_displayed()) << "card contains priority";
        EXPECT_FALSE(card.find_element(TASK_PRIORITY).text().empty()) << "priority is not empty";
    }
}
```
