# Security Adapter Implementation Template

## Rules

- Pure unit tests in test code -- no Laravel context
- Constructor injection via type-hinted parameters in production code
- JWT operations via `firebase/php-jwt` library, configuration via `JwtConfig` readonly class
- Use `Clock` interface for time operations (inject `FakeClock` in tests)

## Reference (read before generating)

- JWT service: `backend/adapters/security/src/JwtService.php`
- Config: `backend/adapters/security/src/JwtConfig.php`
- Middleware: `backend/adapters/security/src/Middleware/SessionAuthMiddleware.php`
- Routes: `backend/adapters/security/src/routes/security.php`
- User ID resolver: `backend/adapters/security/src/Middleware/UserIdMiddleware.php`

## Key Paths

- Production: `backend/adapters/security/src/`
- Tests: `backend/adapters/security/tests/`
