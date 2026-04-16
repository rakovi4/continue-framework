# Email Adapter Implementation Template -- C++/CMake

## Rules

- Extend `AbstractMailSender` for shared template loading and sending logic
- Implement the port interface defined in usecase (e.g., `INotificationSender`, `IDeadlineReminderSender`)
- HTML templates live in `resources/templates/`

## Reference (read before generating)

- Abstract base: `backend/adapters/email/src/service/abstract_mail_sender.h`
- Existing sender: `backend/adapters/email/src/service/notification_sender.cpp`
- Port interfaces: `backend/usecase/include/usecase/adapters/`

## Pattern

1. Inherit from `AbstractMailSender`
2. Implement port interface method
3. Load HTML template via `load_template("template-name.html")`
4. Replace placeholders in template (`std::string::replace` or `std::regex_replace`)
5. Call `send_html_email(to, subject, body)` from base class

## HTML Template

- Create in `backend/adapters/email/resources/templates/`
- Use `{placeholder}` syntax for dynamic values
- Must be valid HTML with proper encoding

## Key Paths

- Senders: `backend/adapters/email/src/service/`
- Headers: `backend/adapters/email/include/email/service/`
- Templates: `backend/adapters/email/resources/templates/`
- Port interfaces: `backend/usecase/include/usecase/adapters/`
