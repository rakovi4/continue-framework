# Test Review Patterns: REST Adapter Layer (Go/stdlib)

Go/testify code examples for REST controller test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Go-Specific Rules (REST)

1. **Use assert message parameter** -- always pass a description string as the last argument to `assert.*` / `require.*` for clear failure messages
2. **Use exact values in mock expectations, not mock.Anything** -- when the expected argument is known, match it exactly. Strict mocks catch controller bugs that `mock.Anything` misses.
3. **No mock.Anything + AssertCalled when exact match suffices** -- if the expected argument is known, set up the mock with the exact value instead of using `mock.Anything` followed by `AssertCalled` with a manual field check.

## Anti-Pattern Examples

### BAD: mock.Anything when exact value is known
```go
mockUsecase.On("Execute", mock.Anything, mock.Anything).Return(expectedResponse, nil)

// GOOD: assert exact expected value
mockUsecase.On("Execute", expectedUserID, expectedRequest).Return(expectedResponse, nil)
```

### BAD: mock.Anything + AssertCalled instead of exact match
```go
mockUsecase.On("Execute", mock.Anything, mock.Anything).Return(expectedResponse, nil)
// ... run handler ...
mockUsecase.AssertCalled(t, "Execute", expectedUserID, mock.MatchedBy(func(r SomeRequest) bool {
    return r.Field == "monthly" && r.Active == true
}))

// GOOD: set up mock with exact values -- strict mock catches wrong arguments immediately
mockUsecase.On("Execute", expectedUserID, SomeRequest{Field: "monthly", Active: true}).
    Return(expectedResponse, nil)
```
