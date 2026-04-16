# Email Adapter Implementation Template -- Go/stdlib

## Rules

- Embed `AbstractMailSender` (or compose) for shared template loading and sending logic
- Implement the port interface defined in usecase (e.g., `NotificationSender`, `DeadlineReminderSender`)
- HTML templates live in `templates/`

## Reference (read before generating)

- Abstract base: `backend/adapters/email/shared/abstract_sender.go`
- Existing sender: `backend/adapters/email/{feature}/{feature}_sender.go`
- Port interfaces: `backend/usecase/port/`

## Pattern

1. Embed or compose `AbstractMailSender`
2. Implement port interface method
3. Load HTML template via `s.LoadTemplate("template-name.html")`
4. Replace placeholders in template (e.g., `strings.ReplaceAll(tmpl, "{token}", token)`)
5. Call `s.SendHTMLEmail(to, subject, body)` from base

## HTML Template

- Create in `backend/adapters/email/templates/`
- Use `{placeholder}` syntax for dynamic values
- Must be valid HTML with proper encoding

## Key Paths

- Senders: `backend/adapters/email/{feature}/`
- Templates: `backend/adapters/email/templates/`
- Port interfaces: `backend/usecase/port/`
