# Extract Method — Java Examples

Use these examples under the shared `.claude/templates/refactoring/extract-method.md`
and `.claude/templates/refactoring/restraint.md` contracts. They illustrate Java
syntax; applicability and exemptions are identical across languages.

## Extract Blank Line Wrapped Sections

Blank lines inside a method often group operations by purpose. For each group,
ask what it does; extract the block into a method whose name expresses that intent.
A section comment can supply the name. Preserve essential comment information
under the source-comment rule.

Apply `.claude/templates/refactoring/restraint.md` to cohesive test recipes and blocks sharing intermediate
state. Spacing between imports, declarations, or methods is outside this heuristic.
The fix is a named extraction, never deleting whitespace or joining statements.
Keep readable spacing in both the caller and extracted methods.

## Extract Named Computation
```java
// Before — repeated expression, unnamed concept
long seconds = ChronoUnit.SECONDS.between(now, expiresAt.plus(GRACE_PERIOD));
// ...
if (now.isBefore(expiresAt.plus(GRACE_PERIOD))) {
// After — named private method, single source of truth
private Instant endOfGracePeriod() {
    return expiresAt.plus(GRACE_PERIOD);
}
```

## Replace Local Variable with Private Method
Extract a distinct or repeated computation into its owning method. Retain simple
meaningful locals and snapshots under shared A8; an expression's syntax alone
does not require extraction. This example isolates construction of an association.
```java
// Before — local variable names a computation
public Task toDomain() {
    Optional<TaskAssignment> assignment = assigneeId != null && columnId != null
            ? Optional.of(TaskAssignment.of(assigneeId, columnId))
            : Optional.empty();
    return new Task(boardId, title, assignment);
}
// After — private method, calling method reads clean
public Task toDomain() {
    return new Task(boardId, title, taskAssignment());
}
private Optional<TaskAssignment> taskAssignment() {
    return assigneeId != null && columnId != null
            ? Optional.of(TaskAssignment.of(assigneeId, columnId))
            : Optional.empty();
}
```

## Extract Sequential Independent Blocks
Extract sequential operations with distinct responsibilities into named methods. Pass intermediate values explicitly; shared values do not prevent decomposition.

```java
// Before — 5 independent validations inline, each a distinct concern
public void validate() {
    if (page < 1) {
        throw new ValidationException("Page number must be at least 1");
    }
    if (size < 1 || size > 100) {
        throw new ValidationException("Page size must be between 1 and 100");
    }
    from.flatMap(f -> to.filter(f::isAfter)).ifPresent(t -> {
        throw new ValidationException("From date must not be after to date");
    });
    priority.ifPresent(p -> parseOrThrow(p, TaskPriority::from, "Invalid priority: " + p));
    boardId.ifPresent(id -> parseOrThrow(id, UUID::fromString, "Invalid boardId: " + id));
}

// After — parent reads as a checklist, each step self-documenting
public void validate() {
    validatePage();
    validateSize();
    validateDateRange();
    validatePriority();
    validateBoardId();
}
```

**Heuristic:** Enumerate each responsibility and its inputs/outputs. Extract mixed concerns regardless of method length or shared values.

## Extract Guard Method
When consecutive guards (find + validate) protect the same concern, extract a void method.
The main method reads as a clean sequence; the guard encapsulates all precondition checks.
```java
// Before — inline guards clutter the happy path
Task task = taskStorage.findById(taskId)
        .orElseThrow(() -> new TaskNotFoundException("..."));
if (task.isArchived()) {
    throw new TaskArchivedException("...");
}
// ... happy path ...

// After — single named guard, main method reads clean
checkTask(taskId);
// ... happy path ...

private void checkTask(UUID taskId) {
    Task task = taskStorage.findById(taskId)
            .orElseThrow(() -> new TaskNotFoundException("..."));
    if (task.isArchived()) {
        throw new TaskArchivedException("...");
    }
}
```

## Decompose Long Method (>10 lines)
Methods over 10 lines almost always mix abstraction levels or handle multiple concerns.
Extract one private method per concern so the parent reads as a clean sequence of named steps.
```java
// Before — 13 lines, mixes raw storage access with named assertions
public void assertBoardUpdatedForUser(UserResponse user) {
    List<Task> tasks = taskStorage.findAll();
    assertThat(tasks).as("saved tasks count").hasSize(2);
    assertTask(tasks, "task-1", ...);
    assertTask(tasks, "task-2", ...);
    List<Column> columns = columnStorage.findAll();
    assertThat(columns).as("saved columns count").hasSize(3);
    assertColumn(columns, "TODO", ...);
    assertColumn(columns, "IN_PROGRESS", ...);
    assertNotificationsProcessed(user.userId(), ...);
    assertAuditLogUpdated(user.userId(), ...);
}
// After — 4 lines, every line at the same abstraction level
public void assertBoardUpdatedForUser(UserResponse user) {
    assertTasksSaved();
    assertColumnsCreated();
    assertNotificationsProcessed(user.userId(), ...);
    assertAuditLogUpdated(user.userId(), ...);
}
```

## Parameterize Near-Duplicate Blocks
When 2+ code blocks share the same structure but differ in literal values,
extract the structure into a method and make the differing values parameters.
```java
// Before — two blocks, identical structure, different data
private void stubCompletedTask(String taskId) {
    stubEndpoint("""{"id": "%s", "status": "done", "archived": true}"""
            .formatted(taskId));
}
private void stubPendingTask(String taskId) {
    stubEndpoint("""{"id": "%s", "status": "todo", "archived": false}"""
            .formatted(taskId));
}
// After — parameterize the varying literals
private String taskBody(String id, String status, boolean archived) {
    return """{"id": "%s", "status": "%s", "archived": %s}"""
            .formatted(id, status, archived);
}
```

## Decompose Pipeline
When a method contains an inline multi-step pipeline (stream, async, IntStream), extract each
transformation step as a named method so the parent reads as a clean sequence of delegation calls.
```java
// Before — inline pipeline mixes orchestration with transformation
public void sendConcurrentNotifications(String event) {
    CountDownLatch latch = new CountDownLatch(1);
    CompletableFuture[] futures = IntStream.range(0, CONCURRENT_COUNT)
            .mapToObj(i -> CompletableFuture.runAsync(latchedNotification(event, latch)))
            .toArray(CompletableFuture[]::new);
    latch.countDown();
    CompletableFuture.allOf(futures).get(10, TimeUnit.SECONDS);
}
// After — each pipeline step is a named method
public void sendConcurrentNotifications(String event) {
    CountDownLatch latch = new CountDownLatch(1);
    CompletableFuture[] futures = runNotificationsAsync(event, latch);
    latch.countDown();
    CompletableFuture.allOf(futures).get(10, TimeUnit.SECONDS);
}
private CompletableFuture[] runNotificationsAsync(String event, CountDownLatch latch) {
    return IntStream.range(0, CONCURRENT_COUNT)
            .mapToObj(i -> sendNotificationAsync(event, latch))
            .toArray(CompletableFuture[]::new);
}
private CompletableFuture<Void> sendNotificationAsync(String event, CountDownLatch latch) {
    return CompletableFuture.runAsync(() -> latchedNotification(event, latch));
}
```

## Extract Method
```java
// Before
String h = Base64.getUrlEncoder().withoutPadding().encodeToString(header.getBytes());
String p = Base64.getUrlEncoder().withoutPadding().encodeToString(payload.getBytes());
// After
private static String base64(String value) {
    return Base64.getUrlEncoder().withoutPadding().encodeToString(value.getBytes());
}
```
