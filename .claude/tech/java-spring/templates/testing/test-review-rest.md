# Test Review Patterns: REST Adapter Layer (Java/Spring)

Java/Mockito code examples for REST controller test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Java-Specific Rules (REST)

1. **Use .as()** -- always describe what you're validating with AssertJ's `.as()` for clear failure messages
2. **Use eq() not any() in Mockito mocks** -- add `@EqualsAndHashCode` to request classes, use `eq(new Request(...))` instead of `any(Request.class)`. Strict mocks catch controller bugs that `any()` misses
3. **No ArgumentCaptor when eq() suffices** -- if the expected argument is known, use `eq()` in `when()` instead of `any()` + captor + `verify()`

## Anti-Pattern Examples

### BAD: any() in Mockito when() when exact value is known
```java
when(usecase.execute(eq(USER_ID), any(SomeRequest.class)))
    .thenReturn(expectedResponse);
// Should use eq() with exact expected request — add @EqualsAndHashCode
when(usecase.execute(eq(USER_ID), eq(new SomeRequest("monthly", true))))
    .thenReturn(expectedResponse);
```

### BAD: any() + ArgumentCaptor instead of eq()
```java
when(usecase.execute(eq(USER_ID), any(SomeRequest.class)))
    .thenReturn(expectedResponse);
ArgumentCaptor<SomeRequest> captor = ArgumentCaptor.forClass(SomeRequest.class);
verify(usecase).execute(eq(USER_ID), captor.capture());
assertThat(captor.getValue().getField()).isEqualTo("expected");
// Should just use eq() — strict mock catches wrong arguments immediately
```
