# Security Adapter Implementation Template -- C++/CMake

## Rules

- No framework context in tests — pure unit tests with GMock
- Use constructor injection in production code
- JWT operations via `JwtService`, configuration via `JwtProperties` struct
- Use `IClock` interface for time operations (inject `FakeClock` in tests)

## Reference (read before generating)

- JWT service: `backend/adapters/security/src/jwt_service.cpp`
- Properties: `backend/adapters/security/src/jwt_properties.h`
- Filter: `backend/adapters/security/src/filter/session_auth_filter.cpp`
- Config: `backend/adapters/security/src/config/security_config.h`

## Key Paths

- Production: `backend/adapters/security/src/`
- Headers: `backend/adapters/security/include/security/`
- Tests: `backend/adapters/security/tests/`
