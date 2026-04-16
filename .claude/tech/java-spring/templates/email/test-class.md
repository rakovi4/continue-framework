# Email Adapter Test Template

## Test Class Rules

- Extend `EmailTest` base class (provides GreenMail lifecycle, `assertEmailSent()`, `loadTemplate()`)
- `@SpringBootTest(classes = EmailTestConfiguration.class)` is inherited from base class
- Autowire the sender class under test (e.g., `NotificationSender`, `DeadlineReminderSender`)
- Use `@Description` with Gherkin-style description

## Email-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Empty method body (no mail sent) | `Expecting actual not to be empty` (no received messages) |
| Wrong template used | Body content mismatch |

## Reference (read before generating)

- Base test class: `backend/adapters/email/src/test/java/com/example/email/EmailTest.java`
- Test configuration: `backend/adapters/email/src/test/java/com/example/email/EmailTestConfiguration.java`
- Existing test: `backend/adapters/email/src/test/java/com/example/email/service/SpringMailNotificationSenderTest.java`
- Existing test: `backend/adapters/email/src/test/java/com/example/email/service/SpringMailDeadlineReminderSenderTest.java`
- Production code: `backend/adapters/email/src/main/java/com/example/email/service/AbstractMailSender.java`
- Templates: `backend/adapters/email/src/main/resources/templates/`

## Base Class Methods

`EmailTest` provides:
- `receivedMessages()` — returns `List<MimeMessage>` captured by GreenMail
- `loadTemplate(String name)` — loads HTML template from classpath `/templates/{name}`
- `assertEmailSent(String recipientEmail, String expectedSubject, String expectedBody)` — asserts exactly one email with correct from, recipient, subject, content type, and body
- `@AfterEach cleanupEmails()` — purges all messages between tests

## Naming Convention

- Test class: `SpringMail{SenderName}Test.java`
- Test method: `sends{EmailType}Email` or `should{ExpectedBehavior}`

## Key Paths

- Tests: `backend/adapters/email/src/test/java/com/example/email/service/`
- Production: `backend/adapters/email/src/main/java/com/example/email/service/`
- Templates: `backend/adapters/email/src/main/resources/templates/`
