# Email Adapter Test Template

## Test Class Rules

- Use test email server (e.g., `nodemailer` mock transport or `smtp-tester` / `mailhog` in tests)
- Import base test setup with email lifecycle helpers (`assertEmailSent()`, `receivedMessages()`)
- Inject the sender class under test
- Use `describe("Feature: ...")` with Gherkin-style description

## Email-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Empty function body (no mail sent) | `Expected received messages not to be empty` |
| Wrong template used | Body content mismatch |

## Reference (read before generating)

- Base test setup: `backend/adapters/email/src/__tests__/setup/EmailTest.ts`
- Existing test: `backend/adapters/email/src/__tests__/service/NotificationSender.test.ts`
- Production code: `backend/adapters/email/src/service/AbstractMailSender.ts`
- Templates: `backend/adapters/email/src/templates/`

## Base Setup Methods

`EmailTest` provides:
- `receivedMessages()` — returns captured messages from mock transport
- `loadTemplate(name: string)` — loads HTML template from `templates/{name}`
- `assertEmailSent(recipientEmail, expectedSubject, expectedBody)` — asserts email with correct from, recipient, subject, content type, and body
- `afterEach` cleanup — purges all messages between tests

## Naming Convention

- Test file: `{SenderName}.test.ts`
- Test case: `it("should send {email type} email")`

## Key Paths

- Tests: `backend/adapters/email/src/__tests__/service/`
- Production: `backend/adapters/email/src/service/`
- Templates: `backend/adapters/email/src/templates/`
