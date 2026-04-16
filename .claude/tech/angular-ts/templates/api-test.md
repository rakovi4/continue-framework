# Frontend API Client Test Template

See `.claude/templates/workflow/api-test-pre-check.md` for the full pre-check procedure.

## Test File

Location: `frontend/src/app/features/{feature}/__tests__/{feature}.api.spec.ts`

```typescript
import { http, HttpResponse } from 'msw'
import { server } from '@test/msw-server'
import { registerUser } from '../logic/registration.api'
import type { RegistrationRequest } from '../logic/types'
import { environment } from '@env/environment'

const BASE = environment.apiUrl

describe('Registration API Client', () => {
  it('should register user successfully', async () => {
    const request: RegistrationRequest = {
      email: 'user@example.com',
      password: 'SecurePass123',
      passwordConfirmation: 'SecurePass123',
    }

    server.use(
      http.post(`${BASE}/api/v1/auth/register`, async ({ request: req }) => {
        const body = await req.json()
        return HttpResponse.json(
          { message: 'Registration successful.', email: body.email },
          { status: 201 }
        )
      })
    )

    const response = await registerUser(request)

    expect(response.email).toBe('user@example.com')
    expect(response.message).toBe('Registration successful.')
  })

  it('should handle validation error', async () => {
    server.use(
      http.post(`${BASE}/api/v1/auth/register`, () => {
        return HttpResponse.json(
          { error: 'ValidationException', message: 'Invalid email format', timestamp: '2026-01-01T00:00:00Z' },
          { status: 400 }
        )
      })
    )

    await expect(registerUser({ email: 'invalid', password: '123', passwordConfirmation: '123' }))
      .rejects.toThrow('Invalid email format')
  })
})
```

## Stub

Create minimal stub in `logic/{feature}.api.ts`:

```typescript
import type { RegistrationRequest, RegistrationResponse } from './types'
import { environment } from '@env/environment'

const BASE_URL = environment.apiUrl

export async function registerUser(request: RegistrationRequest): Promise<RegistrationResponse> {
  throw new Error('Not implemented')
}
```

## MSW Setup

MSW server lifecycle is handled globally in `src/test/setup.ts`. Individual tests add handlers via `server.use(...)`.

## Test Verification

```
Skill tool: skill="test-frontend", args="--testPathPattern={feature}.api"
```
