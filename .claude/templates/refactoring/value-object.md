# Replace Primitive with Value Object

**When to use:** A primitive (String, int) represents a domain concept with validation or behavior.

**Examples:** Email, UserId, Money, Token, Password

## Step 1: Create Value Object in Domain

Location: `backend/domain/src/main/java/com/example/domain/{entity}/`

```java
@Getter
@EqualsAndHashCode
public class Email {
    public static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    private final String value;

    public Email(String email) {
        validate(email);
        this.value = email;
    }

    private void validate(String value) {
        if (value == null || !EMAIL_PATTERN.matcher(value).matches()) {
            throw new ValidationException("Invalid email format");
        }
    }
}
```

Key: `@Getter` + `@EqualsAndHashCode` + validation in constructor + immutable

## Step 2: Update Entity

```java
// Before: private final String email;
// After:  private final Email email;

public User(..., String email, ...) {
    this.email = new Email(email);  // Validate on construction
}
```

## Step 3: Update Port Interface

```java
// Before: Optional<User> findByEmail(String email);
// After:  Optional<User> findByEmail(Email email);
```

## Step 4: Update Adapters

**H2 Storage** — unwrap for JPA: `repository.findByEmail(email.getValue())`

**Fake Storage** — compare value objects: `user.getEmail().equals(email)`

## Step 5: Update Request/DTO Classes

```java
public Email toEmail() {
    return new Email(getEmail());
}
```

## Step 6: Remove Old Validation from Usecase

Validation now happens in constructor — delete `validateEmail()` methods.

## Checklist

1. [ ] Create value object in domain
2. [ ] Update entity that contains it
3. [ ] Update port interface in usecase
4. [ ] Update H2 adapter (use `.getValue()` for JPA)
5. [ ] Update fake storage in tests
6. [ ] Update request classes (add `toX()`)
7. [ ] Remove validation from usecase
8. [ ] Run `./gradlew build`

## Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| FakeStorage comparison fails | Use `equals()` on value objects |
| JPA query fails | Use `email.getValue()` for repository |
| Missing `@EqualsAndHashCode` | Value objects need proper equality |
