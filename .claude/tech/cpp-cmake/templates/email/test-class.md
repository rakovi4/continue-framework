# Email Adapter Test Template -- C++/CMake

## Test Class Rules

- Use Google Test fixture with a `FakeSmtpServer` that captures sent emails in-memory
- Construct the sender class under test with the fake SMTP server
- Use descriptive test names with `DISABLED_` prefix

## Email-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Empty method body (no mail sent) | `EXPECT_FALSE(fake_smtp.captured_emails().empty())` fails |
| Wrong template used | Body content mismatch |

## Reference (read before generating)

- Test fixture base: `backend/adapters/email/tests/email_test_fixture.h`
- Existing test: `backend/adapters/email/tests/service/notification_sender_test.cpp`
- Production code: `backend/adapters/email/src/service/abstract_mail_sender.h`
- Templates: `backend/adapters/email/resources/templates/`

## Fixture Methods

`EmailTestFixture` provides:
- `fake_smtp()` — returns reference to `FakeSmtpServer` with `captured_emails()` method
- `load_template(std::string_view name)` — loads HTML template from resources
- `assert_email_sent(email, subject, body)` — asserts exactly one email with correct fields
- `TearDown()` — clears captured emails between tests

## Naming Convention

- Test class: `{SenderName}Test`
- Test method: `sends_{email_type}_email` or `should_{expected_behavior}`

## Key Paths

- Tests: `backend/adapters/email/tests/service/`
- Production: `backend/adapters/email/src/service/`
- Templates: `backend/adapters/email/resources/templates/`
