# Simplify Expressions

When to use: noisy syntax obscures intent — static imports, method references, or inlining make it clearer.

## Static Import Enum Values
```java
// Before — qualified enum references clutter conditionals
if (status != TaskStatus.TODO && column.hasCapacity()) {
    return TaskStatus.IN_PROGRESS;
}
return TaskStatus.DONE;
// After — static import makes logic read naturally
import static com.example.domain.task.TaskStatus.*;
if (status != TODO && column.hasCapacity()) {
    return IN_PROGRESS;
}
return DONE;
```

## Replace Lambda with Method Reference
```java
// Before
.map(user -> new UserLoginResponse(user.getId(), user.getEmail()))
// After
.map(UserLoginResponse::from)
```

## Inline Method (Remove Thin Wrapper)
When a method only delegates to another method with hardcoded args, inline it — callers
call the real method directly with explicit args.
```java
// Before — wrapper hides what it configures
taskMock.stubCreateHighPriority();
taskMock.stubCreateLowPriority();
// wrappers:
void stubCreateHighPriority() { stubCreateTask(TASK_ID, "HIGH", "TODO"); }
void stubCreateLowPriority()  { stubCreateTask(TASK_ID, "LOW", "TODO"); }
// After — callers see the actual parameters, wrappers deleted
taskMock.stubCreateTask(TASK_ID, "HIGH", "TODO");
taskMock.stubCreateTask(TASK_ID, "LOW", "TODO");
```

## Remove Single-Value Parameter
When a parameter receives the same value at every call site, remove it and inline the constant.
```java
// Before — parameter always receives TASK_ID
sendNotification(TaskApiMock.TASK_ID);
private void sendNotification(String taskId) { ... taskId ... }
// After — constant inlined, parameter removed
sendNotification();
private void sendNotification() { ... TaskApiMock.TASK_ID ... }
```

## Replace Loop with Pipeline
Replace imperative for-loops with collection pipelines (Fowler's "Replace Loop with Pipeline").
```java
// Before — forEach: imperative loop with multi-line body
for (Task task : tasks) {
    assertThat(task.title()).as("title").isEqualTo(expectedTitle);
    assertThat(task.status()).as("status").isEqualTo(expectedStatus);
}
// After — extract body, use method reference
tasks.forEach(this::assertTaskDetails);

// Before — filter + collect: loop with conditional accumulation
List<Task> doneTasks = new ArrayList<>();
for (Task task : tasks) {
    if (task.status().equals("done")) {
        doneTasks.add(task);
    }
}
// After — stream pipeline
var doneTasks = tasks.stream()
        .filter(task -> task.status().equals("done"))
        .toList();

// Before — map + collect: loop transforms elements
List<UUID> ids = new ArrayList<>();
for (Task task : tasks) {
    ids.add(task.taskId());
}
// After — stream pipeline
var ids = tasks.stream()
        .map(Task::taskId)
        .toList();
```

## Unwrap Functional Factory
When a method returns a functional interface (`Runnable`, `Supplier`, `Callable`) wrapping its body
in a lambda, convert it to a direct method. The caller wraps at the call site — one clean line of
`CompletableFuture.runAsync(() -> method())` vs. a nested lambda factory.
```java
// Before — factory returns Runnable, body hidden inside lambda
private Runnable latchedNotification(String event, CountDownLatch latch) {
    return () -> {
        try {
            latch.await();
            sendNotificationWithValidToken(event);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    };
}
CompletableFuture.runAsync(latchedNotification(event, latch));
// After — method does the work directly, caller wraps
private void latchedNotification(String event, CountDownLatch latch) {
    try {
        latch.await();
        sendNotificationWithValidToken(event);
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
    }
}
CompletableFuture.runAsync(() -> latchedNotification(event, latch));
```

## Inline Variable

**NEVER inline a local variable that isolates a side-effecting call from a pure return mapping.** Any call to an injected dependency (usecase, port, repository, API client) is side-effecting regardless of verb — `getTasks()` hits the DB just like `save()` does. The variable exists to separate the side effect from the value transformation — removing it buries side effects inside expressions where they are invisible and reordering-sensitive. See `coding-rules.md` "Don't extract local variables" exception.

```java
// Before — single-accessor local
var taskId = createTaskResponse.taskId();
columnStatements.moveTask(userLoginResponse, taskId);
// After — use object.field() directly
columnStatements.moveTask(userLoginResponse, createTaskResponse.taskId());

// Before — var used once in lambda
var request = createRequest();
assertThatThrownBy(() -> process(request))...
// After
assertThatThrownBy(() -> process(createRequest()))...

// KEEP — side-effecting call isolated from return mapping
var tasks = taskStorage.findByColumnId(columnId);  // side effect: DB read
return buildResponse(tasks);                       // pure mapping
// WRONG — inlining buries the side effect
return buildResponse(taskStorage.findByColumnId(columnId));

// KEEP — usecase call is always side-effecting (DB read), even with "get" verb
var board = boardUseCase.getBoard(userId, page, pageSize);
return ResponseEntity.ok(BoardResponseDto.fromDomain(board));
// WRONG — inlining a usecase call
return ResponseEntity.ok(BoardResponseDto.fromDomain(
        boardUseCase.getBoard(userId, page, pageSize)));
```
