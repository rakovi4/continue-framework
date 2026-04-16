# Email Adapter Test Template

## Test Class Rules

- Use `django.core.mail.outbox` for capturing sent emails (Django test email backend)
- Import base test setup with email lifecycle helpers (`assert_email_sent()`, `received_messages()`)
- Inject the sender class under test
- Use class-level docstring with Gherkin-style description

## Email-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Empty method body (no mail sent) | `assert len(mail.outbox) > 0` fails |
| Wrong template used | Body content mismatch |

## Reference (read before generating)

- Base test setup: `backend/adapters/email/tests/conftest.py`
- Existing test: `backend/adapters/email/tests/service/test_notification_sender.py`
- Production code: `backend/adapters/email/src/service/abstract_mail_sender.py`
- Templates: `backend/adapters/email/src/templates/`

## Base Setup Methods

Test conftest provides:
- `received_messages()` -- returns `django.core.mail.outbox` messages
- `load_template(name: str)` -- loads HTML template from `templates/{name}`
- `assert_email_sent(recipient_email, expected_subject, expected_body)` -- asserts exactly one email with correct from, recipient, subject, content type, and body
- `autouse` fixture cleanup -- clears outbox between tests

## Naming Convention

- Test file: `test_{sender_name}.py`
- Test method: `test_sends_{email_type}_email` or `test_should_{expected_behavior}`

## Key Paths

- Tests: `backend/adapters/email/tests/service/`
- Production: `backend/adapters/email/src/service/`
- Templates: `backend/adapters/email/src/templates/`
