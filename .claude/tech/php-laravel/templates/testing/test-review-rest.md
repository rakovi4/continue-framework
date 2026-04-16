# Test Review Patterns: REST Adapter Layer (PHP/Laravel)

PHP/Mockery code examples for REST controller test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## PHP-Specific Rules (REST)

1. **Use descriptive assertion messages** -- add a third argument to `assertEquals` or use named assertions for clear failure messages
2. **Use exact expected values in mock setups** -- `$mock->shouldHaveReceived('execute')->with($exactRequest)->once()` instead of `$mock->shouldHaveReceived('execute')`. Add `equals()` to request DTOs. Strict mocks catch controller bugs that loose matchers miss
3. **No Mockery::any() when exact value is known** -- if the expected argument is known, use the exact value in `shouldHaveReceived(...)->with()`
4. **No ArgumentCaptor-style patterns when exact match suffices** -- if the expected argument is known, use the exact value in `with()` instead of capturing and asserting separately

## Anti-Pattern Examples

### BAD: Mockery::any() when exact value is known
```php
$mockUsecase->shouldHaveReceived('execute')->with(USER_ID, Mockery::any());
// Should use exact expected request
$mockUsecase->shouldHaveReceived('execute')->with(USER_ID, $expectedRequest);
```

### BAD: any() + capture instead of exact match
```php
$mockUsecase->shouldHaveReceived('execute')
    ->with(USER_ID, Mockery::on(function ($arg) use (&$captured) {
        $captured = $arg;
        return true;
    }));
$this->assertEquals('expected', $captured->field);
// Should just use exact value -- strict mock catches wrong arguments immediately
$mockUsecase->shouldHaveReceived('execute')
    ->with(USER_ID, Mockery::on(fn($arg) => $arg->equals(new SomeRequest('monthly', true))));
```
