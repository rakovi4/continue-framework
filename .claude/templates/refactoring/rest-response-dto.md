# Wrap in REST Response DTO

## Smell

Controller returns raw usecase record/object directly. JSON field names use Java camelCase instead of API snake_case convention. Breaks clients expecting snake_case.

## Fix

Create a REST-layer response DTO record with `@JsonProperty` annotations and a `from()` factory method.

## Steps

1. Identify the usecase response being returned directly
2. Create response DTO record in `rest/dto/{feature}/`
3. Add `@JsonProperty("snake_case")` for multi-word fields
4. Add `from(UsecaseResponse)` factory method
5. Update controller: `ResponseEntity.ok(ResponseDto.from(response))`
6. Update controller test expected JSON to use snake_case
7. Run tests

## Before

```java
// Controller
var response = usecase.execute(request);
return ResponseEntity.ok(response);
// Returns: {"redirectUrl": "...", "createdAt": "..."}
```

## After

```java
// DTO
public record CreateTaskResponseDto(
        @JsonProperty("task_id") String taskId,
        String title,
        String status
) {
    public static CreateTaskResponseDto from(CreateTaskResponse response) {
        return new CreateTaskResponseDto(
                response.taskId(),
                response.title(),
                response.status()
        );
    }
}

// Controller
var response = usecase.execute(request);
return ResponseEntity.ok(CreateTaskResponseDto.from(response));
// Returns: {"task_id": "...", "title": "Fix login bug", "status": "todo"}
```

## When to Apply

- Controller returns usecase record/object without `@JsonProperty`
- API response uses camelCase but project convention is snake_case
- Acceptance test fails with `UnrecognizedPropertyException`
- Follow existing pattern: `TaskResponse`, `BoardResponse`
