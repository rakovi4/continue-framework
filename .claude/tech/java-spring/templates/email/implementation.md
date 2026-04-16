# Email Adapter Implementation Template

## Rules

- Extend `AbstractMailSender` for shared template loading and sending logic
- Implement the port interface defined in usecase (e.g., `NotificationSender`, `DeadlineReminderSender`)
- Use `@Component` annotation for Spring discovery
- HTML templates live in `src/main/resources/templates/`

## Reference (read before generating)

- Abstract base: `backend/adapters/email/src/main/java/com/example/email/service/AbstractMailSender.java`
- Existing sender: `backend/adapters/email/src/main/java/com/example/email/service/SpringMailNotificationSender.java`
- Existing sender: `backend/adapters/email/src/main/java/com/example/email/service/SpringMailDeadlineReminderSender.java`
- Port interfaces: `backend/usecase/src/main/java/com/example/usecase/adapters/`

## Pattern

1. Extend `AbstractMailSender`
2. Implement port interface method
3. Load HTML template via `loadTemplate("template-name.html")`
4. Replace placeholders in template (e.g., `template.replace("{token}", token)`)
5. Call `sendHtmlEmail(to, subject, body)` from base class

## HTML Template

- Create in `backend/adapters/email/src/main/resources/templates/`
- Use `{placeholder}` syntax for dynamic values
- Must be valid HTML with proper encoding

## Key Paths

- Senders: `backend/adapters/email/src/main/java/com/example/email/service/`
- Templates: `backend/adapters/email/src/main/resources/templates/`
- Port interfaces: `backend/usecase/src/main/java/com/example/usecase/adapters/`
