# Red Phase -- C#/xUnit Conventions

Universal formats and rules: `.claude/templates/workflow/red-phase-formats.md`

## [Fact(Skip)] Syntax

```csharp
[Fact(Skip = "RED: FindByEmail returns null")]
public void Should_Find_User_By_Email()
```

Per-method (adapter tests):

```csharp
[Fact(Skip = "RED: EfCoreTaskStorage.FindByBoardId not implemented")]
public void Should_Find_Tasks_By_Board_Id()
```
