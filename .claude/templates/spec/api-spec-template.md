# API Spec — Document Templates

## endpoints.md Format

```markdown
# [Story Name] - API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /api/v1/... | ... |

## Notes

- [1-3 bullets only, if needed]
```

## OpenAPI YAML Format

This is a valid generic example. Adapt the path, operation, schemas, and status
codes to the endpoint. Omit `requestBody` for operations that do not accept one.
Keep string fields as strings; square brackets in YAML introduce arrays.

```yaml
openapi: 3.0.3
info:
  title: Resource API
  version: 1.0.0

paths:
  /api/v1/resources:
    post:
      summary: Create a resource
      operationId: createResource
      tags:
        - resources
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateResourceRequest'
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ResourceResponse'
        '400':
          description: Validation error
        '401':
          description: Unauthorized
        '500':
          description: Internal server error

components:
  schemas:
    CreateResourceRequest:
      type: object
      required: [value]
      properties:
        value:
          type: string
    ResourceResponse:
      type: object
      properties:
        value:
          type: string
```
