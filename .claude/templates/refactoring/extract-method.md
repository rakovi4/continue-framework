# Extract Method

When to use: a method is too long, mixes abstraction levels, repeats an expression, buries preconditions inline, or has commented sections separated by blank lines.

## Extract Commented Sections
When code is organized with comments or followed by blank lines, each commented block is a named concern. Extract each block to a method named after its comment. The comment text becomes the method name.

```java
// Before — commented sections signal separate concerns
// Normal save-load-save cycle — forces version round-trip through domain
var loaded = storage.findByTaskId(task.getTaskId()).orElseThrow();
loaded.archive();
em.clear();
storage.save(loaded);
em.flush();
em.clear();

// First handler saves successfully — bumps version
firstRead.markComplete();
storage.save(firstRead);
em.flush();
em.clear();

// After — each comment became a method name
archive(task);
updateAndSave(firstRead);
```

**Heuristic:** When you see `// comment` followed by a code block followed by a blank line, extract the block as a method named after the comment. The comment is already doing the naming work for you.

## Extract Blank Line Wrapped Sections
When code blocks are separated by blank lines without comments, each block is an unnamed concern. You must derive the method name from what the code does.

```java
// Before — blank lines signal separate concerns but no names provided
var user = storage.findById(userId).orElseThrow();

if (user.getRole() != UserRole.ADMIN) {
    throw new AccessDeniedException("Admin only");
}

task.archive();
storage.save(task);

// After — each blank-separated block extracted with derived names
User admin = requireAdmin(userId);
archiveTask(task);
```

**Heuristic:** When you see a blank line, ask "what concern ends here?" The answer becomes the method name. Unlike commented sections, you must infer the purpose from the code itself.

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
When a local variable names a non-trivial computation (conditional, ternary, multi-step),
replace it with a private method. The calling method becomes a clean one-liner;
the computation gets a named home. Don't inline — that buries complexity in an argument.
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
When a method is a flat sequence of independent operations — each small and cohesive, not sharing intermediate state — extract each into a named private method. The parent becomes a readable table of contents. The trigger is structural independence, not method length: even a short method benefits when its blocks represent distinct concerns.

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

**Heuristic:** Count independent operations in sequence. If 3+ blocks each handle a distinct concern and share no intermediate state, extract them — regardless of total line count or whether blank lines/comments separate them.

## Extract Guard Method
When consecutive guards (find + validate) protect the same concern, extract a void method.
The main method reads as a clean sequence; the guard encapsulates all precondition checks.
```java
// Before — inline guards clutter the happy path
var task = taskStorage.findById(taskId)
        .orElseThrow(() -> new TaskNotFoundException("..."));
if (task.isArchived()) {
    throw new TaskArchivedException("...");
}
// ... happy path ...

// After — single named guard, main method reads clean
checkTask(taskId);
// ... happy path ...

private void checkTask(UUID taskId) {
    var task = taskStorage.findById(taskId)
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
    var latch = new CountDownLatch(1);
    var futures = IntStream.range(0, CONCURRENT_COUNT)
            .mapToObj(i -> CompletableFuture.runAsync(latchedNotification(event, latch)))
            .toArray(CompletableFuture[]::new);
    latch.countDown();
    CompletableFuture.allOf(futures).get(10, TimeUnit.SECONDS);
}
// After — each pipeline step is a named method
public void sendConcurrentNotifications(String event) {
    var latch = new CountDownLatch(1);
    var futures = runNotificationsAsync(event, latch);
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
