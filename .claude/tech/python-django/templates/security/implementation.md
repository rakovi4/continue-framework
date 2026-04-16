# Security Adapter Implementation Template

## Rules

- Pure unit tests in test code -- no Django context
- Constructor injection via `__init__` parameters in production code
- JWT operations via `JwtService` (using `PyJWT`), configuration via `JwtConfig` dataclass
- Use `Clock` protocol for time operations (inject `FakeClock` in tests)

## Reference (read before generating)

- JWT service: `backend/adapters/security/src/jwt_service.py`
- Config: `backend/adapters/security/src/jwt_config.py`
- Middleware: `backend/adapters/security/src/middleware/session_auth_middleware.py`
- URL config: `backend/adapters/security/src/config/security_urls.py`
- User ID resolver: `backend/adapters/security/src/middleware/user_id_middleware.py`

## Key Paths

- Production: `backend/adapters/security/src/`
- Tests: `backend/adapters/security/tests/`
