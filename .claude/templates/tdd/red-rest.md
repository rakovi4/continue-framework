# Controller Test Template -- Universal

## Test Pattern

1. **Setup**: mock use-case response
2. **Execute**: HTTP request
3. **Verify**: compare JSON response against expected object

## Request DTO

Create in the adapter's DTO directory with `toUsecaseRequest()` conversion method.

## HTTP Status Code Mapping

| Scenario Type | Expected Status |
|--------------|-----------------|
| Successful creation | `201 Created` |
| Successful query | `200 OK` |
| Validation error | `400 Bad Request` |
| Authentication error | `401 Unauthorized` |
| Not found | `404 Not Found` |
