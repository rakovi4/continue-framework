# Security Adapter Implementation Template

## Rules

- No Spring context in tests — pure unit tests with Mockito
- Use `@RequiredArgsConstructor` for constructor injection in production code
- JWT operations via `JwtService`, configuration via `JwtProperties`
- Use `Clock` for time operations (inject fixed clock in tests)

## Reference (read before generating)

- JWT service: `backend/adapters/security/src/main/java/com/example/security/JwtService.java`
- Properties: `backend/adapters/security/src/main/java/com/example/security/JwtProperties.java`
- Filter: `backend/adapters/security/src/main/java/com/example/security/filter/SessionAuthenticationFilter.java`
- Config: `backend/adapters/security/src/main/java/com/example/security/config/SecurityWebMvcConfigurer.java`
- Resolver: `backend/adapters/security/src/main/java/com/example/security/userIdResolver/UserIdArgumentResolver.java`

## Key Paths

- Production: `backend/adapters/security/src/main/java/com/example/security/`
- Tests: `backend/adapters/security/src/test/java/com/example/security/`
