# Email Adapter Implementation Template

## Rules

- Extend `AbstractMailSender` for shared template loading and sending logic
- Implement the port interface defined in usecase (e.g., `NotificationSender`, `DeadlineReminderSender`)
- Use Laravel Mailable classes for email construction
- Blade templates live in `resources/views/`

## Reference (read before generating)

- Abstract base: `backend/adapters/email/src/Service/AbstractMailSender.php`
- Existing sender: `backend/adapters/email/src/Service/NotificationSender.php`
- Port interfaces: `backend/usecase/src/Adapters/`

## Pattern

1. Extend `AbstractMailSender`
2. Implement port interface method
3. Create a Mailable class in `src/Mail/` that loads the Blade view
4. Pass data to Mailable via constructor
5. Call `Mail::to($recipient)->send(new CustomMailable($data))` from sender

## Mailable Class

- Create in `backend/adapters/email/src/Mail/`
- Extend `Illuminate\Mail\Mailable`
- Use `Envelope` and `Content` methods (Laravel 9+)
- Pass dynamic values via constructor properties

## Blade Template

- Create in `backend/adapters/email/resources/views/`
- Use `{{ $variable }}` syntax for dynamic values
- Must be valid HTML with proper encoding

## Key Paths

- Senders: `backend/adapters/email/src/Service/`
- Mailables: `backend/adapters/email/src/Mail/`
- Views: `backend/adapters/email/resources/views/`
- Port interfaces: `backend/usecase/src/Adapters/`
