# Flatten Control Flow

When to use: nested branches or manual Optional handling make the logic harder to follow than it needs to be.

## Flatten Nested Conditionals
```java
// Before — nested if, negative condition first
if (columnPosition >= totalColumns - 1) {
    if (hasSubtasks() && !allSubtasksDone()) {
        return BLOCKED;
    }
    return DONE;
}
return IN_PROGRESS;
// After — flat if/return chain, happy path first, no nesting
if (columnPosition < totalColumns - 1) {
    return IN_PROGRESS;
}
if (hasSubtasks() && !allSubtasksDone()) {
    return BLOCKED;
}
return DONE;
```

## Optional: Replace isPresent/get with ifPresentOrElse
```java
// Before — isPresent()/get() anti-pattern
var existing = findTask(id);
if (existing.isPresent()) {
    tasks.remove(existing.get());
    tasks.add(new Task(id, status, now));
} else {
    tasks.add(new Task(id, status, now));
}
// After — let Optional drive branching
findTask(id).ifPresentOrElse(
        task -> task.moveTo(status),
        () -> addNewTask(id, status, now));
```

## Delegate Mutation to Child Entity
```java
// Before — parent manipulates child's state via remove/add
tasks.remove(existing);
tasks.add(new Task(id, newStatus, now));
// After — child owns its mutation
task.moveTo(newStatus);
// moveTo() checks column ordering internally and updates only if valid
```
