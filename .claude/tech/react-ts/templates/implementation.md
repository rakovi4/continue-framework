# Frontend Implementation Template

## Logic Implementation (.logic.ts)

```typescript
export function validateEmail(email: string): ValidationResult {
  if (!email) return { valid: false, error: 'Email is required' }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return { valid: false, error: 'Invalid email format' }
  return { valid: true }
}

export function isFormValid(state: RegistrationFormState): boolean {
  return validateEmail(state.email).valid
    && validatePassword(state.password).valid
    && state.password === state.confirmPassword
}

export function buildRegistrationRequest(state: RegistrationFormState): RegistrationRequest {
  return { email: state.email, password: state.password, passwordConfirmation: state.confirmPassword }
}
```

## API Client Implementation (.api.ts)

```typescript
const BASE_URL = import.meta.env.VITE_API_URL ?? ''

export async function registerUser(request: RegistrationRequest): Promise<RegistrationResponse> {
  const response = await fetch(`${BASE_URL}/api/v1/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(request),
  })

  if (!response.ok) {
    const error = await response.json()
    throw new Error(error.message)
  }

  return response.json()
}
```

## Humble Object Component (.tsx)

Build AFTER logic and API are tested. Components live in `components/` subdirectory.

Page component (`components/{Feature}Page.tsx`) — orchestrates state and composes field components:

```tsx
import { useState } from 'react'
import { validateEmail, buildRegistrationRequest } from '../logic/registration.logic'
import { registerUser } from '../logic/registration.api'
import { EmailField } from './EmailField'
import type { RegistrationFormState } from '../logic/types'

export function RegistrationPage() {
  const [form, setForm] = useState<RegistrationFormState>(getInitialFormState)
  const [isLoading, setIsLoading] = useState(false)

  const updateField = (field: keyof RegistrationFormState, value: string | boolean) => {
    setForm(prev => ({ ...prev, [field]: value }))
  }

  const submitForm = async () => {
    if (isLoading) return
    setIsLoading(true)
    await registerUser(buildRegistrationRequest(form)).catch(() => {})
  }

  return (
    <form onSubmit={handleSubmit}>
      <EmailField value={form.email} onChange={v => updateField('email', v)} />
      {/* ... other field components ... */}
    </form>
  )
}
```

Field components (`components/{FieldName}.tsx`) — encapsulate label + input + error for one field:

```tsx
export function EmailField({ value, error, onChange, onBlur }: EmailFieldProps) {
  return (
    <div>
      <label htmlFor="email">Email</label>
      <input data-testid="email-input" value={value} onChange={e => onChange(e.target.value)} onBlur={onBlur} />
      {error && <FieldError message={error} />}
    </div>
  )
}
```

## Test Verification

```
Skill tool: skill="test-frontend", args="{feature}"
```
