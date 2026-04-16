# Acceptance Test Implementation (Green Phase) -- C#/ASP.NET Core

> Universal workflow: `.claude/templates/tdd/green-acceptance.md`

## Tech-Specific Details

- **Disable marker**: `[Fact(Skip = "...")]` — remove `Skip` parameter to enable, re-add on failure
- **Test target**: `FullyQualifiedName~{ClassName}` (dotnet test `--filter` value)
- **Error terminology**: "exception filter" (ASP.NET Core `IExceptionFilter` or middleware)
