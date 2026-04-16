# Red Phase -- PHP/PHPUnit Conventions

Universal formats and rules: `.claude/templates/workflow/red-phase-formats.md`

## markTestSkipped Syntax

```php
$this->markTestSkipped('RED: findByEmail returns null');
```

setUp-level (adapter tests):

```php
public function setUp(): void
{
    parent::setUp();
    $this->markTestSkipped('RED: EloquentTaskStorage::findByBoardId not implemented');
}
```
