# Test Review Patterns: REST Adapter Layer (C++/Google Test)

C++/GMock code examples for REST controller test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## C++-Specific Rules (REST)

1. **Use descriptive failure messages** -- add `<< "description"` to assertions for clear failure output
2. **Use Eq() not _ in GMock expectations** -- add `operator==` to request classes, use `Eq(expected)` instead of `_`. Strict mocks catch controller bugs that `_` misses
3. **No SaveArg when Eq() suffices** -- if the expected argument is known, use `Eq()` in `EXPECT_CALL` instead of `_` + `SaveArg` + `EXPECT_EQ`

## Anti-Pattern Examples

### BAD: _ (wildcard) in GMock when exact value is known
```cpp
EXPECT_CALL(mock_usecase, execute(Eq(USER_ID), _))
    .WillOnce(Return(expected_response));
// GOOD: use Eq() with exact expected request — add operator==
EXPECT_CALL(mock_usecase, execute(Eq(USER_ID), Eq(SomeRequest{"monthly", true})))
    .WillOnce(Return(expected_response));
```

### BAD: _ + SaveArg instead of Eq()
```cpp
SomeRequest captured;
EXPECT_CALL(mock_usecase, execute(Eq(USER_ID), _))
    .WillOnce(DoAll(SaveArg<1>(&captured), Return(expected_response)));
EXPECT_EQ(captured.field(), "expected");
// GOOD: use Eq() — strict mock catches wrong arguments immediately
EXPECT_CALL(mock_usecase, execute(Eq(USER_ID), Eq(SomeRequest{"monthly", true})))
    .WillOnce(Return(expected_response));
```
