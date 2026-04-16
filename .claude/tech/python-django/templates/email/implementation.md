# Email Adapter Implementation Template

## Rules

- Extend `AbstractMailSender` for shared template loading and sending logic
- Implement the port interface defined in usecase (e.g., `NotificationSender`, `DeadlineReminderSender`)
- HTML templates live in `src/templates/`
- Use `django.core.mail.send_mail` or `EmailMessage` for sending

## Reference (read before generating)

- Abstract base: `backend/adapters/email/src/service/abstract_mail_sender.py`
- Existing sender: `backend/adapters/email/src/service/notification_sender.py`
- Port interfaces: `backend/usecase/src/adapters/`

## Pattern

1. Extend `AbstractMailSender`
2. Implement port interface method
3. Load HTML template via `self.load_template("template_name.html")`
4. Replace placeholders in template (e.g., `template.replace("{token}", token)`)
5. Call `self.send_html_email(to, subject, body)` from base class

## HTML Template

- Create in `backend/adapters/email/src/templates/`
- Use `{placeholder}` syntax for dynamic values
- Must be valid HTML with proper encoding

## Key Paths

- Senders: `backend/adapters/email/src/service/`
- Templates: `backend/adapters/email/src/templates/`
- Port interfaces: `backend/usecase/src/adapters/`
