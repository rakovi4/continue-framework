# Test Review Patterns: REST Adapter Layer (Node/TypeScript)

TypeScript/Vitest code examples for REST controller test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## TypeScript-Specific Rules (REST)

1. **Use exact values in mock setups** -- when the expected argument is known, match it exactly instead of using `expect.any()` or `expect.anything()`
2. **No `vi.fn()` with loose matching when exact value is known** -- use `toHaveBeenCalledWith(exact, args)` to verify the controller passes the correct values
3. **Prefer mock resolved value + verify pattern** -- set up `vi.mocked(usecase.execute).mockResolvedValue(result)` then verify with `toHaveBeenCalledWith()`

## Anti-Pattern Examples

### BAD: expect.any() in mock when exact value is known
```typescript
vi.mocked(usecase.execute).mockImplementation((userId, request) => {
    if (userId === USER_ID) return Promise.resolve(expectedResponse);
    throw new Error("unexpected");
});
// GOOD: use exact expected arguments
vi.mocked(usecase.execute).mockResolvedValue(expectedResponse);
// then verify: expect(usecase.execute).toHaveBeenCalledWith(USER_ID, expectedRequest);
```

### BAD: expect.any() + manual extraction instead of exact match
```typescript
vi.mocked(usecase.execute).mockImplementation((userId, request) => {
    if (userId === USER_ID && request.type === "monthly") {
        return Promise.resolve(expectedResponse);
    }
    throw new Error("unexpected");
});
// Should just use mockResolvedValue + toHaveBeenCalledWith — strict mock catches wrong arguments immediately
vi.mocked(usecase.execute).mockResolvedValue(expectedResponse);
expect(usecase.execute).toHaveBeenCalledWith(USER_ID, { type: "monthly", active: true });
```
