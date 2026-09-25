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

## Humble Object Component (.vue)

Build AFTER logic and API are tested. Components live in `components/` subdirectory.

Page component (`components/{Feature}Page.vue`) — orchestrates state and composes field components:

```vue
<script setup lang="ts">
import { ref, reactive } from 'vue'
import { validateEmail, buildRegistrationRequest } from '../logic/registration.logic'
import { registerUser } from '../logic/registration.api'
import EmailField from './EmailField.vue'
import type { RegistrationFormState } from '../logic/types'

const form = reactive<RegistrationFormState>(getInitialFormState())
const isLoading = ref(false)

function updateField(field: keyof RegistrationFormState, value: string | boolean) {
  ;(form as any)[field] = value
}

async function submitForm() {
  if (isLoading.value) return
  isLoading.value = true
  try {
    await registerUser(buildRegistrationRequest(form))
  } catch {
    // handle error
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <form @submit.prevent="submitForm">
    <EmailField :value="form.email" @update="v => updateField('email', v)" />
    <!-- ... other field components ... -->
  </form>
</template>
```

Field components (`components/{FieldName}.vue`) — encapsulate label + input + error for one field:

```vue
<script setup lang="ts">
import FieldError from '@/app/components/ui/FieldError.vue'

defineProps<{
  value: string
  error?: string
}>()

const emit = defineEmits<{
  update: [value: string]
  blur: []
}>()
</script>

<template>
  <div>
    <label for="email">Email</label>
    <input
      data-testid="email-input"
      :value="value"
      @input="emit('update', ($event.target as HTMLInputElement).value)"
      @blur="emit('blur')"
    />
    <FieldError v-if="error" :message="error" />
  </div>
</template>
```

## Test Verification

```
Skill tool: skill="test-frontend", args="{feature}"
```
