# Test Review Patterns: REST Adapter Layer (C#/ASP.NET Core)

C#/Moq code examples for REST controller test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## C#-Specific Rules (REST)

1. **Use `.Because("reason")`** -- always describe what you're validating with FluentAssertions' `.Because()` for clear failure messages
2. **Use exact expected values in mock setups** -- `mockUsecase.Verify(x => x.Execute(expected), Times.Once)` instead of `Times.AtLeastOnce`. Add `IEquatable<T>` or override `Equals` on request records. Strict mocks catch controller bugs that loose matchers miss
3. **No `It.IsAny<T>()` when exact value is known** -- if the expected argument is known, use the exact value in `Verify()`

## Anti-Pattern Examples

### BAD: It.IsAny when exact value is known
```csharp
mockUsecase.Verify(x => x.Execute(USER_ID, It.IsAny<Request>()), Times.Once);
// Should use exact expected request
mockUsecase.Verify(x => x.Execute(USER_ID, expectedRequest), Times.Once);
```

### BAD: It.IsAny + callback capture instead of exact match
```csharp
Request? captured = null;
mockUsecase.Setup(x => x.Execute(USER_ID, It.IsAny<Request>()))
    .Callback<Guid, Request>((id, req) => captured = req)
    .Returns(expectedResponse);
// ...
captured!.Field.Should().Be("expected");
// Should just use exact value -- strict mock catches wrong arguments immediately
mockUsecase.Setup(x => x.Execute(USER_ID, expectedRequest))
    .Returns(expectedResponse);
```

### BAD: Times.AtLeastOnce instead of Times.Once
```csharp
mockUsecase.Verify(x => x.Execute(It.IsAny<Request>()), Times.AtLeastOnce());
// GOOD: verify exact invocation count
mockUsecase.Verify(x => x.Execute(expectedRequest), Times.Once());
```
