# Email Adapter Implementation Template

## Rules

- Extend `AbstractMailSender` for shared template loading and sending logic
- Implement the port interface defined in usecase (e.g., `NotificationSender`, `DeadlineReminderSender`)
- HTML templates live in `src/templates/`

## Reference (read before generating)

- Abstract base: `backend/adapters/email/src/service/AbstractMailSender.ts`
- Existing sender: `backend/adapters/email/src/service/NotificationSender.ts`
- Port interfaces: `backend/usecase/src/adapters/`

## Pattern

1. Extend `AbstractMailSender`
2. Implement port interface method
3. Load HTML template via `this.loadTemplate("template-name.html")`
4. Replace placeholders in template (e.g., `template.replace("{token}", token)`)
5. Call `this.sendHtmlEmail(to, subject, body)` from base class

## HTML Template

- Create in `backend/adapters/email/src/templates/`
- Use `{placeholder}` syntax for dynamic values
- Must be valid HTML with proper encoding

## Key Paths

- Senders: `backend/adapters/email/src/service/`
- Templates: `backend/adapters/email/src/templates/`
- Port interfaces: `backend/usecase/src/adapters/`
