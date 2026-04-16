# Security Adapter Implementation Template -- C#/ASP.NET Core

## Rules

- Pure unit tests in test code — no ASP.NET Core context
- Constructor injection via readonly fields or primary constructor in production code
- JWT operations via `JwtService` (using `System.IdentityModel.Tokens.Jwt` or `Microsoft.IdentityModel.JsonWebTokens`), configuration via `JwtConfig` record
- Use `IClock` interface for time operations (inject `FakeClock` in tests)

## Reference (read before generating)

- JWT service: `backend/Adapters/Security/JwtService.cs`
- Config: `backend/Adapters/Security/JwtConfig.cs`
- Middleware: `backend/Adapters/Security/Middleware/SessionAuthMiddleware.cs`
- Auth config: `backend/Adapters/Security/Config/SecurityConfig.cs`
- User ID resolver: `backend/Adapters/Security/Middleware/UserIdMiddleware.cs`

## Key Paths

- Production: `backend/Adapters/Security/`
- Tests: `backend/Adapters/Security.Tests/`
