# Extract Class

**When to use:** A class exceeds 200 lines, implements 2+ unrelated interfaces, or mixes distinct concerns (e.g., token validation + task fetching + status updating in one adapter). Split into focused classes, then optionally extract a shared base class for common infrastructure.

## Signals

- Class implements multiple port interfaces with unrelated method groups
- Methods cluster into groups that don't call each other
- Different methods use different external base URLs or APIs
- Class has 3+ private helpers that serve only one public method each

## Step 1: Identify Concerns

Group public methods by the concern they serve. Each group that talks to a different API endpoint, uses different dependencies, or implements a different port is a candidate for extraction.

```
Original BoardService (225 lines):
  Concern A: validatePermission()     → permission validation
  Concern B: getTasks(), moveTask(), createTask()  → task management
  Concern C: getColumns(), reorderColumns()        → column management
```

## Step 2: Split Port Interface (if single fat interface)

Before extracting the class, split the port at the usecase layer so each concern has its own interface.

```java
// Before — one fat port
interface BoardService {
    boolean validatePermission(UUID userId, UUID boardId);
    List<Task> getTasks(UUID boardId);
    Task moveTask(UUID taskId, UUID columnId);
    List<Column> getColumns(UUID boardId);
    void reorderColumns(UUID boardId, List<UUID> columnOrder);
}

// After — one port per concern
interface PermissionValidator {
    boolean validatePermission(UUID userId, UUID boardId);
}
interface TaskManager {
    List<Task> getTasks(UUID boardId);
    Task moveTask(UUID taskId, UUID columnId);
}
interface ColumnManager {
    List<Column> getColumns(UUID boardId);
    void reorderColumns(UUID boardId, List<UUID> columnOrder);
}
```

## Step 3: Extract Class Per Concern

Move each method group + its private helpers into a new `@Component` class implementing the narrow port.

```java
// Before — god class
@Component
public class BoardService implements BoardPort {
    // 225 lines: permissions + tasks + columns + shared infra
}

// After — one class per concern
@Component
public class BoardPermissionValidator implements PermissionValidator { ... }

@Component
public class BoardTaskManager implements TaskManager { ... }

@Component
public class BoardColumnManager implements ColumnManager { ... }
```

## Step 4: Update All Callers

- Usecases: inject the narrow port instead of the fat one
- Fakes: split `FakeBoardService` into `FakePermissionValidator`, `FakeTaskManager`, etc.
- Tests: update constructor wiring and Statements classes

## Step 5: Extract Superclass (if siblings share infrastructure)

After splitting, sibling classes often duplicate fields (`apiProperties`) and helper methods (`buildRestClient()`). Extract a base class.

```java
// Shared infrastructure pulled up
public abstract class BaseBoardAdapter {
    protected final BoardProperties boardProperties;

    protected BaseBoardAdapter(BoardProperties boardProperties) {
        this.boardProperties = boardProperties;
    }

    protected RestClient buildRestClient(String baseUrl) {
        return RestClient.builder().baseUrl(baseUrl).build();
    }
}

// Subclasses become lean
@Component
public class BoardTaskManager extends BaseBoardAdapter implements TaskManager {
    public BoardTaskManager(BoardProperties boardProperties) {
        super(boardProperties);
    }
    // only task-specific methods
}
```

## Step 6: Deduplicate Within Each Class

After splitting, look for duplicated HTTP call patterns within the extracted class. Consolidate into a shared private method.

```java
// Before — 3 methods each building the same POST call
getTasks()        → buildRestClient().post().uri(TASK_API_URI).header(...).body(...).retrieve()...
getTaskDetails()  → buildRestClient().post().uri(TASK_API_URI).header(...).body(...).retrieve()...
moveTask()        → buildRestClient().post().uri(TASK_API_URI).header(...).body(...).retrieve()...

// After — single shared method
private TaskResponseDto postTaskApi(UUID boardId, Object requestBody) { ... }
```

## Checklist

1. [ ] Concerns identified and grouped
2. [ ] Port interfaces split at usecase layer
3. [ ] Classes extracted — one per concern
4. [ ] All callers updated (usecases, fakes, tests, Statements)
5. [ ] Shared infrastructure extracted to base class (if applicable)
6. [ ] Internal duplication consolidated within each class
7. [ ] Size verified — `wc -l` on all resulting files, each ≤200 lines. If any exceeds, recurse (split further)
8. [ ] Tests pass (`./gradlew build`)
