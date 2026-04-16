# Replace Map with Typed DTO

## Smell

`Map<String, Object>` or nested `Map.of()` used as HTTP request body. Untyped, typos in keys silently break the API call, hard to read.

## Fix

Create a typed DTO class with `@JsonProperty` for field name mapping and a `from()` factory method for conversion.

## Steps

1. Identify the Map structure and field names
2. Create DTO class with matching fields
3. Add `@JsonProperty` for snake_case or non-Java field names
4. Add `from()` factory method for conversion from domain/usecase object
5. Replace Map usage with `DTO.from(source)`
6. Run tests

## Before

```java
private Map<String, Object> toNotificationRequest(SendNotificationRequest request) {
    return Map.of(
            "recipient", Map.of(
                    "user_id", String.valueOf(request.userId()),
                    "channel", request.channel()
            ),
            "content", Map.of(
                    "type", "task_update",
                    "template_id", "task-moved"
            ),
            "message", request.message()
    );
}
```

## After

```java
@Value
@Builder
public class NotificationGatewayRequest {
    Recipient recipient;
    Content content;
    String message;

    @Value @Builder
    public static class Recipient {
        @JsonProperty("user_id") String userId;
        String channel;
    }

    @Value @Builder
    public static class Content {
        String type;
        @JsonProperty("template_id") String templateId;
    }

    public static NotificationGatewayRequest from(SendNotificationRequest request) {
        return NotificationGatewayRequest.builder()
                .recipient(Recipient.builder()
                        .userId(String.valueOf(request.userId()))
                        .channel(request.channel())
                        .build())
                .content(Content.builder()
                        .type("task_update")
                        .templateId("task-moved")
                        .build())
                .message(request.message())
                .build();
    }
}
```

Usage: `.body(NotificationGatewayRequest.from(request))`

## When to Apply

- Any `Map<String, Object>` used as HTTP request/response body
- Nested `Map.of()` calls (especially 2+ levels deep)
- JSON structures sent to external APIs
