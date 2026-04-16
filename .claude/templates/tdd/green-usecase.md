# Usecase Implementation Template -- Universal

## Rules

- Replace the not-implemented marker with actual logic
- Implement MINIMAL code -- only what's needed for this test to pass
- Use-case calls adapter, may use domain logic

## Domain Classes (if needed)

- Factory methods (e.g., `User.create(...)`)
- Business logic methods
- Keep domain pure (no framework dependencies)

## Adapter Interfaces (if needed)

- Add methods to existing interfaces
- Also update fake implementations in test code
