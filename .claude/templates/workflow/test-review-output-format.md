# Test Review Output Format

Record results for every applicable row in `test-review-checklist.md`, including
rows beyond this summary. Store evidence once and reference it from phase records
under `quality-execution.md`; this summary is not a substitute for the full check
coverage. Include findings, resolutions, and pending joined verification explicitly.

Summary format:

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
