# Subselect Read Model

Replace manual row grouping / multi-repository queries in storage adapters with a `@Subselect` entity.

## When to apply

- Storage method uses `Collectors.groupingBy()` + `Map.Entry` to reassemble flat rows
- Storage injects 2+ repositories to make separate queries
- `@ElementCollection List<Long>` needs joins to other entities
- Intermediate Row/Projection DTOs exist only to carry query results for manual assembly
- Usecase injects 2+ storage ports and queries them sequentially (N+1 pattern) — the aggregate is too thin

## Steps

1. **Identify the aggregate** — what domain object does the storage method return? (e.g., `BoardView` = board + columns + tasks)
2. **Write the SQL subselect** — a `SELECT DISTINCT` that filters eligible rows and produces one row per aggregate root (typically per `user_id`). Include PKs of related entities as columns.
3. **Create `@Subselect` entity** with:
   - `@Entity @Immutable @Subselect("...")`
   - `@Synchronize({"table1", "table2", ...})` listing ALL source tables
   - `@Id` on the natural grouping key (e.g., `userId`)
   - `@OneToOne` for single related entities — join by PK (include target PK in subselect)
   - `@OneToMany` for collection relationships — join by FK matching `@Id`
   - `toDomain()` that maps everything
4. **Replace the repository** — plain Spring Data `JpaRepository<Entity, ID>` interface
5. **Simplify the storage** — should become: `repository.findAll().stream().map(Entity::toDomain).toList()`
6. **Delete** intermediate Row/Projection DTOs, helper methods, extra repository dependencies

## Usecase side: enrich the aggregate

When a usecase injects multiple storage ports and queries them sequentially, the fix is on both sides:

**Before** — thin aggregate, usecase does N+1 queries:
```java
// BAD: 4 dependencies, sequential storage queries mid-execution
public class GetBoardView {
    private final BoardStorage boardStorage;
    private final ColumnStorage columnStorage;                // extra port
    private final TaskStorage taskStorage;                    // extra port
    private final NotificationSender notificationSender;

    public void execute() {
        boardStorage.findByUserId(userId).stream()
            .forEach(board -> {
                var columns = columnStorage.findByBoardId(board.id());  // N+1
                columns.forEach(column ->
                    taskStorage.findByColumnId(column.id()));           // N+1
            });
    }
}
```

**After** — rich aggregate, single fetch:
```java
// GOOD: 2 dependencies, everything loaded upfront
public class GetBoardView {
    private final BoardStorage boardStorage;
    private final NotificationSender notificationSender;

    public void execute() {
        boardStorage.findBoardView(userId).stream()  // rich aggregate
            .forEach(board ->
                board.columns().forEach(column ->
                    column.tasks()                       // data already on the aggregate
                        .forEach(task -> notificationSender.notifyIfOverdue(task))));
    }
}
```

Steps:
1. Identify what data the usecase fetches from each extra port
2. Add that data to the domain aggregate (e.g., `columns` on `BoardView`, `tasks` on `Column`)
3. Expand the single storage port to return the enriched aggregate
4. Remove the extra port dependencies from the usecase
5. Update the storage adapter (use `@Subselect` or JPA relationships to load everything in one query)
6. Update fakes to provide the enriched aggregate in tests

## Storage side: consolidate queries

## Before

```java
// BAD: flat rows + manual grouping + status map + helper methods
@Service
@RequiredArgsConstructor
public class H2FooStorage implements FooStorage {
    private final FooJpaRepository fooRepo;
    private final BarJpaRepository barRepo;  // multiple repos!
    private final BazJpaRepository bazRepo;

    public List<Foo> findAll() {
        var rows = fooRepo.findFlatRows();
        return rows.stream()
            .collect(Collectors.groupingBy(FooRow::bar))  // manual grouping
            .entrySet().stream()
            .map(entry -> toFoo(entry, buildStatusMap(rows)))  // helper methods
            .toList();
    }
}
```

## After

```java
// GOOD: @Subselect entity with JPA relationships
@Entity
@Immutable
@Subselect("""
    SELECT DISTINCT b.user_id AS user_id, b.id AS bar_id, z.token AS baz_token
    FROM bars b
    JOIN bazs z ON z.user_id = b.user_id
    JOIN foos f ON f.user_id = b.user_id
    JOIN foo_items fi ON fi.foo_id = f.id
    JOIN statuses s ON s.item_id = fi.item_id
    """)
@Synchronize({"bars", "bazs", "foos", "foo_items", "statuses"})
public class FooCandidateEntity {
    @Id
    @Column(name = "user_id")
    private UUID userId;

    @OneToOne
    @JoinColumn(name = "bar_id", insertable = false, updatable = false)
    private BarEntity bar;

    @OneToMany
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private List<FooEntity> foos;

    @Column(name = "baz_token")
    private String bazToken;

    public FooCandidate toDomain() {
        return new FooCandidate(bar.toDomain(), foos.stream().map(FooEntity::toDomain).toList(), bazToken);
    }
}

// Storage becomes trivial
@Service
@RequiredArgsConstructor
public class H2FooStorage implements FooStorage {
    private final FooCandidateJpaRepository repo;

    public List<FooCandidate> findAll() {
        return repo.findAll().stream().map(FooCandidateEntity::toDomain).toList();
    }
}
```

## @Subselect gotchas

- **`@OneToOne` join on non-PK column fails silently** — Hibernate ignores `referencedColumnName` with `@Subselect`. Always include the target entity's PK in the subselect and join by PK.
- **`@Synchronize` is mandatory** — without it, Hibernate won't auto-flush pending inserts before querying the subselect, causing missing data.
- **L1 cache staleness in tests** — when setup and query happen in the same `@DataJpaTest` transaction, entities cached during setup have stale relationships. Fix in the test with `entityManager.flush() + clear()` before querying — never in production code.

## ElementCollection → Entity

When `@ElementCollection List<Long>` needs to join other entities:

```java
// BAD: @ElementCollection — can't have @ManyToOne
@ElementCollection
@CollectionTable(name = "task_items", joinColumns = @JoinColumn(name = "task_id"))
@Column(name = "item_id")
private List<Long> itemIds;

// GOOD: proper entity with composite key + read-only join
@Entity
@Table(name = "task_items")
@IdClass(TaskItemEntity.TaskItemId.class)
public class TaskItemEntity {
    @Id
    @Column(name = "task_id")
    private UUID taskId;

    @Id
    @Column(name = "item_id")
    private Long itemId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "task_id", insertable = false, updatable = false)
    private TaskEntity task;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "item_id", insertable = false, updatable = false)
    private StatusEntity status;  // read-only join — statuses managed elsewhere
}
```
