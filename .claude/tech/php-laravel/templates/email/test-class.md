# Email Adapter Test Template

## Test Class Rules

- Use `Mail::fake()` for capturing sent emails (Laravel mail faking)
- Use `Mail::assertSent()`, `Mail::assertNotSent()` for verification
- Inject the sender class under test
- Add `#[TestDox('...')]` with Gherkin-style description

## Email-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Empty method body (no mail sent) | `Mail::assertSent(...)` fails |
| Wrong Mailable used | Class mismatch in `assertSent` |

## Reference (read before generating)

- Base test setup: `backend/adapters/email/tests/TestCase.php`
- Existing test: `backend/adapters/email/tests/Service/NotificationSenderTest.php`
- Production code: `backend/adapters/email/src/Service/AbstractMailSender.php`
- Mailables: `backend/adapters/email/src/Mail/`

## Base Setup Methods

Test setup provides:
- `Mail::fake()` -- activates mail faking in `setUp()`
- `Mail::assertSent(MailableClass::class, fn($mail) => ...)` -- assert mail sent with correct data
- `Mail::assertNotSent(MailableClass::class)` -- assert no mail of type sent
- Automatic cleanup between tests via Laravel test lifecycle

## Naming Convention

- Test file: `{SenderName}Test.php`
- Test method: `test_sends_{email_type}_email` or `test_should_{expected_behavior}`

## Key Paths

- Tests: `backend/adapters/email/tests/Service/`
- Production: `backend/adapters/email/src/Service/`
- Mailables: `backend/adapters/email/src/Mail/`
- Views: `backend/adapters/email/resources/views/`
