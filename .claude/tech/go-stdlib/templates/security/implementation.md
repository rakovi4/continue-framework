# Security Adapter Implementation Template -- Go/stdlib

## Rules

- Pure unit tests in test code — no HTTP server context
- Constructor injection via struct fields set in `New*(...)` factory functions
- JWT operations via `JWTService` using `github.com/golang-jwt/jwt/v5`, configuration via `JWTConfig`
- Password hashing via `golang.org/x/crypto/bcrypt` (or `argon2` for new projects)
- Use `Clock` interface for time operations (inject `FakeClock` in tests)

## Reference (read before generating)

- JWT service: `backend/adapters/security/jwt/jwt_service.go`
- Config: `backend/adapters/security/config/jwt_config.go`
- Middleware: `backend/adapters/security/middleware/session_auth_middleware.go`
- Router config: `backend/adapters/security/config/security_router.go`
- User ID resolver: `backend/adapters/security/middleware/userid_middleware.go`

## Key Paths

- Production: `backend/adapters/security/`
- Tests: `backend/adapters/security/`
