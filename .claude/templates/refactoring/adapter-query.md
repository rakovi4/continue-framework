# Adapter Query Extraction

Replace static spec utilities, inline query building, and `Object[]` results in storage adapters with a rich adapter query class and typed projection.

## When to apply

- Static utility class builds `Specification` from a query/filter object (e.g., `*Specs.fromQuery(query)`)
- Storage method has inline `Specification` building + `CriteriaQuery` construction + `Object[]` result mapping
- `CriteriaQuery<Object[]>` with `multiselect()` and index-based `result[0]`, `result[1]` access
- Storage method exceeds 10 lines because of query-building logic that obscures the actual storage work

## Pattern 1: Static Specification Utility → Adapter Query

```java
// BAD: static utility extracts fields from query object
class TaskSpecs {
    static Specification<TaskEntity> fromQuery(TaskQuery query) {
        return Specification.where(byUserId(query.userId()))
                .and(query.taskId().map(TaskSpecs::byTaskId).orElse(null))
                .and(query.actionType().map(a -> byActionType(a.value())).orElse(null));
    }
    private static Specification<TaskEntity> byUserId(UUID userId) { ... }
    private static Specification<TaskEntity> byTaskId(UUID taskId) { ... }
}

// GOOD: adapter query extends port query, owns its spec building
public final class AdapterTaskQuery extends TaskQuery {

    public AdapterTaskQuery(TaskQuery query) {
        super(query.userId(), query.taskId(), query.actionType(), query.from(), query.to(), query.page(), query.size());
    }

    Specification<TaskEntity> filters() {
        return Specification.where(byUserId(userId()))
                .and(taskId().map(this::byTaskId).orElse(null))
                .and(actionType().map(a -> byActionType(a.value())).orElse(null));
    }

    PageRequest pageRequest() {
        return PageRequest.of(page() - 1, size(), Sort.by(Sort.Direction.DESC, "createdAt"));
    }

    private Specification<TaskEntity> byUserId(UUID userId) { ... }
    private Specification<TaskEntity> byTaskId(UUID taskId) { ... }
}
```

Three wins: (1) query owns its spec building (move behavior to data), (2) static utility deleted, (3) storage method becomes trivial delegation.

## Pattern 2: `Object[]` Result → Typed Projection

```java
// BAD: untyped array with index-based access + manual null handling
private TaskSummary computeSummary(Specification<TaskEntity> spec) {
    var cb = entityManager.getCriteriaBuilder();
    var cq = cb.createQuery(Object[].class);
    var root = cq.from(TaskEntity.class);
    cq.where(spec.toPredicate(root, cq, cb));
    cq.multiselect(sumCase(cb, statusChanged), sumCase(cb, movedCount), ...);
    var result = entityManager.createQuery(cq).getSingleResult();
    return new TaskSummary(toLong(result[0]), toLong(result[1]), toLong(result[2]), ...);
}
private static long toLong(Object value) { return value != null ? ((Number) value).longValue() : 0L; }

// GOOD: typed projection with constructor matching select columns
class TaskSummaryProjection {
    private final long statusChangedCount;
    private final long movedCount;
    // ...

    TaskSummaryProjection(Long statusChangedCount, Long movedCount, ...) {
        this.statusChangedCount = toLong(statusChangedCount);
        this.movedCount = toLong(movedCount);
    }

    TaskSummary toDomain() {
        return new TaskSummary(statusChangedCount, movedCount, ...);
    }

    private static long toLong(Long value) { return value != null ? value : 0L; }
}
```

The adapter query owns the CriteriaQuery construction with `cb.construct(Projection.class, ...)`:
```java
// In AdapterQuery
CriteriaQuery<TaskSummaryProjection> summary(CriteriaBuilder cb) {
    CriteriaQuery<TaskSummaryProjection> cq = cb.createQuery(TaskSummaryProjection.class);
    Root<TaskEntity> root = cq.from(TaskEntity.class);
    cq.where(filters().toPredicate(root, cq, cb));
    cq.select(cb.construct(TaskSummaryProjection.class, ...));
    return cq;
}
```

## Pattern 3: Simplified Storage

After extracting adapter query + projection, the storage method becomes trivial:

```java
// BAD: 40+ lines of query building, spec construction, result mapping
public TaskPage findPage(TaskQuery query) {
    var spec = TaskSpecs.fromQuery(query);
    var pageable = PageRequest.of(query.page() - 1, query.size(), Sort.by(...));
    var page = repository.findAll(spec, pageable);
    return new TaskPage(
            page.getContent().stream().map(Entity::toDomain).toList(),
            query.page(), query.size(), page.getTotalElements(),
            computeSummary(spec));  // 20 more lines of CriteriaQuery building
}

// GOOD: storage delegates to adapter query
public TaskPage findPage(TaskQuery query) {
    AdapterTaskQuery adapterQuery = new AdapterTaskQuery(query);
    CriteriaBuilder cb = entityManager.getCriteriaBuilder();

    Page<TaskEntity> page = repository.findAll(adapterQuery.filters(), adapterQuery.pageRequest());
    TaskSummary summary = entityManager.createQuery(adapterQuery.summary(cb)).getSingleResult().toDomain();

    return createLogPage(adapterQuery, page, summary);
}
```

## Steps

1. **Identify query building** — spec construction, page request building, CriteriaQuery construction
2. **Check port query class** — if it's a domain record, convert to a usecase adapter class with protected fields (enables adapter extension)
3. **Create AdapterQuery** — `extends PortQuery`, copy constructor from port query, move spec/page/criteria methods
4. **Create Projection** (if `Object[]` exists) — typed class with constructor matching `multiselect` columns, `toDomain()`, null-safe converters
5. **Replace `multiselect` with `cb.construct`** — use the projection class
6. **Simplify storage** — delegate to adapter query methods
7. **Delete** static utility class, private query-building helpers, `toLong`/`toSummary` methods
8. **Run tests** — behavior must be identical

## Port query: record → class

When the port query is a domain record, it can't be extended. Move it to `usecase/adapters/` as a class with protected fields:

```java
// BAD: domain record — adapter can't extend it
package com.example.domain.task;
public record TaskQuery(UUID userId, Optional<UUID> taskId, ...) {}

// GOOD: usecase adapter class — adapter extends it
package com.example.usecase.adapters.task;
public class TaskQuery {
    protected final UUID userId;
    protected final Optional<UUID> taskId;
    // constructor, accessors, equals, hashCode, toString
}
```
