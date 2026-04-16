# Security Adapter Implementation Template

## Rules

- Pure unit tests in test code — no Express context
- Constructor injection with `readonly` fields in production code
- JWT operations via `JwtService`, configuration via `JwtConfig`
- Use `Clock` interface for time operations (inject `FakeClock` in tests)

## Reference (read before generating)

- JWT service: `backend/adapters/security/src/JwtService.ts`
- Config: `backend/adapters/security/src/JwtConfig.ts`
- Middleware: `backend/adapters/security/src/middleware/SessionAuthMiddleware.ts`
- Router config: `backend/adapters/security/src/config/SecurityRouter.ts`
- User ID resolver: `backend/adapters/security/src/middleware/UserIdMiddleware.ts`

## Key Paths

- Production: `backend/adapters/security/src/`
- Tests: `backend/adapters/security/src/__tests__/`
