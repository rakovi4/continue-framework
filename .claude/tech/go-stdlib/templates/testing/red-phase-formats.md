# Red Phase -- Go Conventions

Universal formats and rules: `.claude/templates/workflow/red-phase-formats.md`

## t.Skip Syntax

```go
func TestCreateTask(t *testing.T) {
    t.Run("should create task with valid input", func(t *testing.T) {
        // TDD Red Phase - CreateTask returns not-implemented panic
        t.Skip("TDD Red Phase - CreateTask panics: not implemented")
```

Function-level (adapter tests):

```go
func TestTaskStorage_FindByBoardID(t *testing.T) {
    // TDD Red Phase - FindByBoardID returns nil, nil
    t.Skip("TDD Red Phase - FindByBoardID not implemented")
```
