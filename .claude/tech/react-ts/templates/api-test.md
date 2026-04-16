# Frontend API Client Test Template

## Backend Endpoint Pre-Check

See `.claude/templates/workflow/api-test-pre-check.md` for the full pre-check procedure.

## Test File

Location: `frontend/src/features/{feature}/__tests__/{feature}.api.test.ts`

```typescript
import { describe, it, expect } from 'vitest'
import { http, HttpResponse } from 'msw'
import { server } from '@/test/msw-server'
import { registerUser } from '../logic/registration.api'
import type { RegistrationRequest } from '../logic/types'

const BASE = import.meta.env.VITE_API_URL

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

const BASE_URL = import.meta.env.VITE_API_URL ?? ''

export async function registerUser(request: RegistrationRequest): Promise<RegistrationResponse> {
  throw new Error('Not implemented')
}
```

## MSW Setup

MSW server lifecycle is handled globally in `src/test/setup.ts`. Individual tests add handlers via `server.use(...)`.

## WireMock vs MSW Comparison

| Aspect | Backend (WireMock) | Frontend (MSW) |
|--------|-------------------|----------------|
| Setup | `new WireMockServer(port)` | `setupServer()` |
| Stub | `stubFor(post(...).willReturn(...))` | `server.use(http.post(...))` |
| Cleanup | `wireMockServer.stop()` | `server.close()` |
| Reset | N/A | `server.resetHandlers()` |

## Test Verification

```
Skill tool: skill="test-frontend", args="{feature}.api"
```
