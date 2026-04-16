# Parameterize Test Helper

**When to use:** Test helper uses hardcoded value that varies per test.

## Before

```java
void stubAcceptsToken() {
    wireMock.stubFor(post("/api/v1/token/ping")
        .withHeader("Authorization", equalTo("Bearer HARDCODED_TOKEN"))
        .willReturn(ok()));
}
```

## After

```java
void stubAcceptsToken(String token) {
    wireMock.stubFor(post("/api/v1/token/ping")
        .withHeader("Authorization", equalTo("Bearer " + token))
        .willReturn(ok()));
}
```

## Steps

1. Find hardcoded values in helper methods
2. Add parameter, replace hardcoded value
3. Update callers — pass the value
4. Run tests

## When NOT to Parameterize

- Value is truly constant (API endpoint, header name)
- Value is irrelevant to test behavior
- Only one test uses the helper
