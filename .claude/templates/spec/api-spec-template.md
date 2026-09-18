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

### Payload examples

- Include a concrete payload example for every request body and every documented
  response body, including errors, under its media type in `content`.
- Use `example` for one payload or named `examples` with `summary` and `value`
  for distinct states or schema variants. Cover each documented response variant.
  Never put `example` and `examples` on the same media type object.
- Derive realistic, synthetic values from the endpoint's contract. Keep related
  request and response values consistent; omit credentials and real user data.
  Examples must satisfy their schemas and must not invent fields or behavior.
- Omit payload examples for bodyless responses. For binary downloads, describe
  the artifact and example headers instead of embedding fake binary content.
- Put reusable examples in `components/examples` when helpful and reference them
  from the media type's named `examples`; resolve shared-file references normally.

### Complete document example

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
            example:
              value: Sample value
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ResourceResponse'
              example:
                value: Sample value
        '400':
          description: Validation error
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
              examples:
                missingValue:
                  summary: Required value was omitted
                  value:
                    code: INVALID_REQUEST
                    message: Value is required.
        '401':
          description: Unauthorized
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
              example:
                code: UNAUTHENTICATED
                message: Sign in to continue.
        '500':
          description: Internal server error
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
              example:
                code: INTERNAL_ERROR
                message: The request could not be completed.

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
      required: [value]
      properties:
        value:
          type: string
    ErrorResponse:
      type: object
      required: [code, message]
      properties:
        code:
          type: string
        message:
          type: string
```
