# Extract Factory Method

**When to use:** Same constructor called in multiple places with many null/default arguments.

## Before

```java
return new ValidationResult(false, false, null, "Token expired", null, List.of());
return new ValidationResult(false, false, null, "Invalid format", null, List.of());
```

## After

```java
public static ValidationResult invalid(String errorMessage) {
    return new ValidationResult(false, false, null, errorMessage, null, List.of());
}

// Callers simplified
return ValidationResult.invalid("Token expired");
return ValidationResult.invalid("Invalid format");
```

## Steps

1. Find repeated constructor calls with many null/default args
2. Group by intent — what's different?
3. Create static factory method with meaningful name
4. Replace call sites
5. Run tests

## Naming Conventions

| Pattern | Factory Name |
|---------|--------------|
| Error/invalid state | `invalid(msg)`, `error(msg)`, `failure(msg)` |
| Success/valid state | `success(data)`, `valid(data)`, `ok(data)` |
| Specific case | `expired()`, `notFound()`, `missingPermission()` |
