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
import { environment } from '@env/environment'

const BASE_URL = environment.apiUrl

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

## Humble Object Component

Components live in `components/` subdirectory.

Page component (`components/{feature}-page/{feature}-page.component.ts`) -- orchestrates state and composes field components:

```typescript
import { Component, signal } from '@angular/core'
import { validateEmail, buildRegistrationRequest } from '../../logic/registration.logic'
import { registerUser } from '../../logic/registration.api'
import { EmailFieldComponent } from '../email-field/email-field.component'
import type { RegistrationFormState } from '../../logic/types'

@Component({
  selector: 'app-registration-page',
  standalone: true,
  imports: [EmailFieldComponent],
  templateUrl: './registration-page.component.html',
})
export class RegistrationPageComponent {
  form = signal<RegistrationFormState>(getInitialFormState())
  isLoading = signal(false)

  updateField(field: keyof RegistrationFormState, value: string | boolean) {
    this.form.update(prev => ({ ...prev, [field]: value }))
  }

  async submitForm() {
    if (this.isLoading()) return
    this.isLoading.set(true)
    try {
      await registerUser(buildRegistrationRequest(this.form()))
    } catch { /* handled by UI */ }
    this.isLoading.set(false)
  }
}
```

Page template (`components/{feature}-page/{feature}-page.component.html`):

```html
<form (ngSubmit)="submitForm()">
  <app-email-field
    [value]="form().email"
    (valueChange)="updateField('email', $event)"
  />
</form>
```

Field component (`components/email-field/email-field.component.ts`):

```typescript
import { Component, input, output } from '@angular/core'
import { FieldErrorComponent } from '@shared/components/field-error/field-error.component'

@Component({
  selector: 'app-email-field',
  standalone: true,
  imports: [FieldErrorComponent],
  template: `
    <div>
      <label for="email">Email</label>
      <input data-testid="email-input" [value]="value()" (input)="valueChange.emit($any($event.target).value)" />
      @if (error()) {
        <app-field-error [message]="error()!" />
      }
    </div>
  `,
})
export class EmailFieldComponent {
  value = input.required<string>()
  error = input<string>()
  valueChange = output<string>()
}
```

## Test Verification

```
Skill tool: skill="test-frontend", args="{feature}"
```
