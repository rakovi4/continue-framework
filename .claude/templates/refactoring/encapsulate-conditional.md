# Encapsulate Conditional

**When to use:** Caller has if-else chain checking object's fields to decide action.

## Before

```java
ValidationResult result = validate(input);
if (!result.isValid()) {
    throw new InvalidInputException(result.getErrorMessage());
}
if (!result.hasPermission()) {
    throw new AccessDeniedException();
}
return buildResponse(result);
```

## After

```java
// Method in ValidationResult
public void assertValidWithPermission() {
    if (!isValid()) throw new InvalidInputException(errorMessage);
    if (!hasPermission()) throw new AccessDeniedException();
}

// Caller simplified
ValidationResult result = validate(input);
result.assertValidWithPermission();
return buildResponse(result);
```

## Steps

1. Identify pattern — caller checks fields, then throws/returns based on state
2. Name the operation — what is the caller trying to accomplish?
3. Move to data class — create method that does the checks
4. Update caller — replace if-chain with single method call
5. Run tests

## Variant: Move conditional side-effects into aggregate

**When to use:** Usecase checks a field on the request/event, then calls a method on the aggregate conditionally. The aggregate should own the decision.

### Before

```java
// Usecase — owns the "when to archive" decision
public void process(Request request) {
    var board = storage.findById(request.boardId()).orElseThrow();

    board.moveTask(request.taskId(), request.columnId(), now);

    if (request.isArchiveColumn()) {
        board.archiveTask(request.taskId(), now);
    }

    storage.save(board);
}
```

### After

```java
// Aggregate — owns both the mutation and the conditional side-effect
public void moveTask(UUID taskId, UUID columnId, Instant now) {
    reassignColumn(taskId, columnId, now);
    if (isArchiveColumn(columnId)) {
        archiveTask(taskId, now);
    }
}

// Usecase — just delegates
public void process(Request request) {
    var board = storage.findById(request.boardId()).orElseThrow();
    board.moveTask(request.taskId(), request.columnId(), now);
    storage.save(board);
}
```

### Why

- The aggregate owns its invariants — only it should decide when state transitions happen
- The usecase becomes a thin orchestrator (find → delegate → save)
- The `isArchiveColumn()` method on the request is no longer needed — the board checks internally
- If archiving rules change, only the board changes, not every usecase that calls it

## Common Method Names

| Intent | Method Name |
|--------|-------------|
| Throw if invalid | `assertValid()`, `ensureValid()` |
| Throw if missing permission | `requirePermission()` |
| Combined check | `assertValidWithPermission()` |
| Aggregate mutation + conditional side-effect | `moveTask()`, `processEvent()` |
