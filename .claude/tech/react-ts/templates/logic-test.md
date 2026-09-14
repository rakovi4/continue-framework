# Frontend Logic Test Template

## Test File

Location: `frontend/src/features/{feature}/__tests__/{feature}.logic.test.ts`

```typescript
import { describe, it, expect } from 'vitest'
import { validateEmail, validatePassword, isFormValid, buildRegistrationRequest } from '../logic/registration.logic'

describe('Registration Logic', () => {
  describe('validateEmail', () => {
    it('should return valid for correct email format', () => {
      const result = validateEmail('user@example.com')

      expect(result.valid).toBe(true)
      expect(result.error).toBeUndefined()
    })

    it('should return error for empty email', () => {
      const result = validateEmail('')

      expect(result.valid).toBe(false)
      expect(result.error).toBe('Email is required')
    })
  })
})
```

## Stub

Create minimal stub in `logic/{feature}.logic.ts`:

```typescript
import type { ValidationResult } from './types'

export function validateEmail(email: string): ValidationResult {
  throw new Error('Not implemented')
}
```

## Types

Create `logic/types.ts` if not present:

```typescript
export interface ValidationResult {
  valid: boolean
  error?: string
}
```

## Expected Failure Patterns

| Stub | Expected Failure |
|------|-----------------|
| `throw new Error('Not implemented')` | Error: Not implemented |
| `return undefined` | expect(undefined).toBe(true) fails |
| No function exported | Import error |

## .skip Convention

After verified failure, add `.skip` and encode the failure reason in the test name:

```typescript
it.skip('TDD Red: validateEmail not implemented — returns valid for correct email format', () => {
  expect(validateEmail('valid@example.com')).toBe(true)
})
```

## Test Verification

```
Skill tool: skill="test-frontend", args="{feature}.logic"
```
