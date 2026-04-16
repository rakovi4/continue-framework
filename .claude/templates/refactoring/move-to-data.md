# Move Behavior to Data

When to use: caller extracts fields from an object to compute, serialize, construct, or format — move the logic onto the object that owns the fields.

## Move Behavior to Data
```java
// Before (in caller)
return ValidationResult.success(entry.getExpiresAt(), entry.getType());
// After (on the data object)
public ValidationResult toResult() { return ValidationResult.success(expiresAt, type); }
```

## Move Serialization/Hashing to Data
```java
// Before (in caller)
String json = objectMapper.writeValueAsString(request);
String sig = hmac(json, SECRET);
client.send(json, sig);
// After (in Request DTO)
public String json() { return new ObjectMapper().writeValueAsString(this); }
public String computeSignature() { return hmac(json(), SECRET); }
// Caller becomes:
client.send(request); // client calls request.json() + request.computeSignature()
```

## Extract Convenience Accessor
```java
// Before (in caller) — getter chain / train wreck
loginResponse.getUser().getId().toString()
// After (in LoginResponse)
public String userIdValue() { return getUser().getId().toString(); }
```

## Add `from()` Factory on DTO
When a caller constructs a DTO/record by extracting fields from another object (enum, entity, domain object),
add a `static from()` factory method on the DTO. This moves the mapping logic to the data owner,
enables method reference, and keeps related constants local.
```java
// Before — caller extracts fields and holds the constant
private static final int DEFAULT_POSITION = 0;
return new GetColumnsResponse(Arrays.stream(ColumnType.values())
        .map(type -> new ColumnInfo(
                type.name().toLowerCase(),
                type.getDisplayName(),
                DEFAULT_POSITION))
        .toList());
// After — ColumnInfo owns its construction from ColumnType
// In ColumnInfo record:
public record ColumnInfo(String type, String displayName, int position) {
    private static final int DEFAULT_POSITION = 0;
    public static ColumnInfo from(ColumnType type) {
        return new ColumnInfo(type.name().toLowerCase(), type.getDisplayName(), DEFAULT_POSITION);
    }
}
// Caller becomes:
return new GetColumnsResponse(Arrays.stream(ColumnType.values())
        .map(ColumnInfo::from)
        .toList());
```
Three wins: (1) mapping logic on the data object, (2) lambda → method ref, (3) constant moves to where it's used.

## Extract Cohesive Value Object from Bloated Entity
When an entity has 10+ fields and methods use only a subset, extract a value object for the field cluster.
```java
// Before — Board has 10 fields, permission methods only use ownerId/boardId/visibility
public class Board {
    private UUID id, ownerId; private String name; /* ... 7 more fields */
    public boolean canAccess(UUID userId) {
        return ownerId.equals(userId) || visibility == BoardVisibility.PUBLIC;
    }
}
// After — extract BoardIdentity for the identity cluster
public record BoardIdentity(UUID ownerId, UUID boardId, BoardVisibility visibility) {
    public boolean isOwnedBy(UUID userId) { return ownerId.equals(userId); }
}
// Board delegates identity through the value object
private final BoardIdentity boardIdentity;
public UUID getId() { return boardIdentity.boardId(); }
```

## Extract Parameter Object from Repeating Group
When 3+ parameters repeat across multiple factory methods, extract a record.
```java
// Before — boardId/columnId/taskId repeated in 4 factory methods
TaskEvent.moved(boardId, columnId, taskId, oldStatus, newStatus, at, eventId);
TaskEvent.created(boardId, columnId, taskId, newStatus, at, eventId);
TaskEvent.archived(boardId, columnId, taskId, oldStatus, reason, at, eventId);
// After — BoardIdentity carries the group, overloaded factories accept it
TaskEvent.moved(board, newStatus, at, eventId);
TaskEvent.created(board, newStatus, at, eventId);
// In TaskEvent:
public static TaskEvent moved(BoardIdentity board, String newStatus, ...) {
    return moved(board.boardId(), board.ownerId(), board.visibility(), ...);
}
```

## Instance Transform on Immutable Record
When external code rebuilds a record changing 1-2 fields, add a `toX()` method on the record.
```java
// Before — caller reconstructs Task to change status + updatedAt
new Task(task.id(), task.title(), task.columnId(),
    TaskStatus.ARCHIVED, task.assigneeId(), task.priority(),
    Instant.now(), task.createdAt());
// After — record owns its transformation
public Task toArchived(Instant now) {
    return new Task(id, title, columnId,
        TaskStatus.ARCHIVED, assigneeId, priority,
        now, createdAt);
}
// Caller becomes:
tasks.stream().map(task -> task.toArchived(now))
```

## Extract Builder Factory on Data Class
When callers repeat `X.builder()...build()` (empty case + real case, or across methods),
add a semantic factory method on X. Eliminates builder duplication and names the construction.
```java
// Before — caller builds Paginated in two places (empty + real)
return Paginated.<TaskCard>builder()
        .data(taskCards)
        .pagination(Pagination.builder()
                .totalSize(taskCards.size())
                .page(page).pageSize(pageSize).build())
        .build();
// After — factory on Paginated, reused for both empty and real
return Paginated.paginatedItems(page, pageSize, taskCards);
// In Paginated:
public static Paginated<TaskCard> paginatedItems(Integer page, Integer pageSize, List<TaskCard> cards) {
    return builder().data(cards).pagination(Pagination.getPage(cards.size(), page, pageSize)).build();
}
// In Pagination:
public static Pagination getPage(int totalSize, Integer page, Integer pageSize) {
    return builder().totalSize(totalSize).page(page).pageSize(pageSize).build();
}
```
