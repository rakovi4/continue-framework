# Test Review Output Format

Print this filled checklist before reporting results:

```
## Review Checklist
1. Infrastructure in test class: [grep result or "clean"]
2. Loose string assertions: [grep result or "clean"]
3. Range/direction checks: [grep result or "clean"]
4. Loose mock matchers: [grep result or "clean"]
5. Missing field assertions: [DTO has N fields, M asserted -- or "all covered"]
6. Partial collection coverage: [grep result or "clean" -- verify ALL items asserted, not just first]
7. Shallow object assertions: [list objects and their fields -- or "all fields covered"]
8. Setup leak in test DSL: [grep result or "clean"]
```

If any item has a violation, fix it BEFORE reporting "no issues."
