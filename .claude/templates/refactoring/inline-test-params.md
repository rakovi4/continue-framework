# Inline Test Parameters into Statements

**When to use:** Test creates data then passes to statement's assert method, but statement could create it internally.

## Before

```java
@Test
void should_reject_missing_permission() {
    var loginResponse = statements.loginUser();
    var request = statements.createRequestWithoutPermission();
    statements.assertMissingPermission(loginResponse, request);
}
```

## After

```java
@Test
void should_reject_missing_permission() {
    var loginResponse = statements.loginUser();
    statements.assertMissingPermission(loginResponse);  // Creates request internally
}
```

## Steps

1. Find pattern — test creates object then immediately passes to statement
2. Check — is the object used elsewhere in the test?
3. If only used in assert, move creation into statement
4. Run tests

## When NOT to Inline

- Object is used in multiple statement calls
- Test needs to inspect/modify object between creation and assertion
- Object creation has test-specific configuration
