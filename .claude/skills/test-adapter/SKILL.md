---
name: test-adapter
description: Run adapter module tests. First argument is adapter name (matches directory under backend/adapters/). Use when user wants to run adapter tests or mentions /test-adapter command.
---

# /test-adapter - Run Adapter Tests

## Usage
```
/test-adapter rest
/test-adapter h2 LoginStorageTest
/test-adapter email
/test-adapter h2 TaskStorageTest
```

## Convention

Read `ProductSpecification/technology.md` Conventions table for the backend test command pattern. Adapter name maps to the adapter module path (e.g., `adapters/{adapter}`).

## Action

Parse arguments: first word is adapter name, optional second word is test filter.

Without test filter:
```
{Backend test command} with module = adapters/{adapter}
```

With test filter:
```
{Backend test command} with module = adapters/{adapter}, filtered to *{filter}*
```

## Output

Report the test results from output.
