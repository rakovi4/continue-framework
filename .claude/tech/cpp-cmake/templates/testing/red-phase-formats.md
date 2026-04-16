# Red Phase -- C++/Google Test Conventions

Universal formats and rules: `.claude/templates/workflow/red-phase-formats.md`

## DISABLED_ Prefix Syntax

```cpp
// TDD Red Phase - find_by_email returns std::nullopt
TEST_F(TaskTest, DISABLED_should_find_task_by_email) {
```

Per-test (adapter tests):

```cpp
// TDD Red Phase - SqliteTaskStorage::find_by_board_id not implemented
TEST_F(SqliteTaskStorageFindByBoardIdTest, DISABLED_should_return_tasks_for_board) {
```
