# Email Adapter Test Template -- C#/ASP.NET Core

## Test Class Rules

- Use a test SMTP server (Papercut, smtp4dev) or mock `ISmtpClient` for capturing sent emails
- Import base test setup with email lifecycle helpers (`AssertEmailSent()`, `ReceivedMessages()`)
- Inject the sender class under test
- Add `[Trait("Description", "Gherkin-style scenario")]` for scenario documentation

## Email-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Empty method body (no mail sent) | `receivedMessages.Should().NotBeEmpty()` fails |
| Wrong template used | Body content mismatch |

## Reference (read before generating)

- Base test setup: `backend/Adapters/Email.Tests/TestFixture.cs`
- Existing test: `backend/Adapters/Email.Tests/Service/NotificationSenderTest.cs`
- Production code: `backend/Adapters/Email/Service/AbstractMailSender.cs`
- Templates: `backend/Adapters/Email/Templates/`

## Base Setup Methods

Test fixture provides:
- `ReceivedMessages()` — returns captured email messages
- `LoadTemplate(string name)` — loads HTML template from `Templates/{name}`
- `AssertEmailSent(string recipientEmail, string expectedSubject, string expectedBody)` — asserts exactly one email with correct from, recipient, subject, content type, and body
- `IDisposable` cleanup — clears captured emails between tests

## Naming Convention

- Test file: `{SenderName}Test.cs`
- Test method: `Should_Send_{EmailType}_Email` or `Should_{expected_behavior}`

## Key Paths

- Tests: `backend/Adapters/Email.Tests/Service/`
- Production: `backend/Adapters/Email/Service/`
- Templates: `backend/Adapters/Email/Templates/`
