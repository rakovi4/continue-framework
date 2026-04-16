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

```yaml
openapi: 3.0.3
info:
  title: [Endpoint Title]
  version: 1.0.0

paths:
  /api/v1/[resource]:
    [method]:
      summary: [Brief description]
      operationId: [operationId]
      tags:
        - [resource-tag]
      requestBody:  # if applicable
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/[RequestSchema]'
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/[ResponseSchema]'
        '400':
          description: Validation error
        '401':
          description: Unauthorized
        '500':
          description: Internal server error

components:
  schemas:
    [RequestSchema]:
      type: object
      required: [required-fields]
      properties:
        [field]:
          type: [type]
    [ResponseSchema]:
      type: object
      properties:
        [field]:
          type: [type]
```
