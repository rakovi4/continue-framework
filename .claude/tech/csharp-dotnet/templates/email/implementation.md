# Email Adapter Implementation Template -- C#/ASP.NET Core

## Rules

- Extend `AbstractMailSender` for shared template loading and sending logic
- Implement the port interface defined in usecase (e.g., `INotificationSender`, `IDeadlineReminderSender`)
- HTML templates live in `Templates/`
- Use `SmtpClient` or `MailKit` for sending

## Reference (read before generating)

- Abstract base: `backend/Adapters/Email/Service/AbstractMailSender.cs`
- Existing sender: `backend/Adapters/Email/Service/NotificationSender.cs`
- Port interfaces: `backend/Usecase/Adapters/`

## Pattern

1. Extend `AbstractMailSender`
2. Implement port interface method
3. Load HTML template via `LoadTemplate("template_name.html")`
4. Replace placeholders in template (e.g., `template.Replace("{token}", token)`)
5. Call `SendHtmlEmail(to, subject, body)` from base class

## HTML Template

- Create in `backend/Adapters/Email/Templates/`
- Use `{placeholder}` syntax for dynamic values
- Must be valid HTML with proper encoding

## Key Paths

- Senders: `backend/Adapters/Email/Service/`
- Templates: `backend/Adapters/Email/Templates/`
- Port interfaces: `backend/Usecase/Adapters/`
