# Red Phase -- Python/pytest Conventions

Universal formats and rules: `.claude/templates/workflow/red-phase-formats.md`

## @pytest.mark.skip Syntax

```python
@pytest.mark.skip(reason="RED: find_by_email returns None")
class TestFindUserByEmail:
```

Class-level (adapter tests):

```python
@pytest.mark.skip(reason="RED: DjangoTaskStorage.find_by_board_id not implemented")
class TestDjangoTaskStorageFindByBoardId:
```
