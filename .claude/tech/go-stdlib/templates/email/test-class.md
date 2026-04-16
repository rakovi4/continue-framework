# Email Adapter Test Template -- Go/stdlib

## Test Class Rules

- Use test SMTP server (e.g., `mailhog` container or `smtpmock` library in tests)
- Import base test setup with email lifecycle helpers (`AssertEmailSent()`, `ReceivedMessages()`)
- Inject the sender struct under test
- Use `t.Run("scenario description", ...)` subtests with Gherkin-style description

## Email-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Empty function body (no mail sent) | `Expected received messages not to be empty` |
| Wrong template used | Body content mismatch |

## Reference (read before generating)

- Base test setup: `backend/adapters/email/testutil/email_test_setup.go`
- Existing test: `backend/adapters/email/{feature}/{feature}_sender_test.go`
- Production code: `backend/adapters/email/{feature}/{feature}_sender.go`
- Templates: `backend/adapters/email/templates/`

## Base Setup Methods

`EmailTestSetup` provides:
- `ReceivedMessages()` — returns captured messages from mock SMTP
- `LoadTemplate(name string)` — loads HTML template from `templates/{name}`
- `AssertEmailSent(t, recipientEmail, expectedSubject, expectedBody)` — asserts email with correct from, recipient, subject, content type, and body
- Cleanup between tests — purges all messages

## Naming Convention

- Test file: `{sender_name}_test.go`
- Test function: `Test{SenderName}(t *testing.T)`
- Subtest: `t.Run("should send {email type} email", ...)`

## Key Paths

- Tests: `backend/adapters/email/{feature}/`
- Production: `backend/adapters/email/{feature}/`
- Templates: `backend/adapters/email/templates/`
