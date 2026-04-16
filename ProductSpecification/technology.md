# Technology Profile

tech-profile:
  backend: java-spring
  frontend: react-ts
  css: tailwind
  browser-testing: selenium

## Backend

| Concern | Technology |
|---------|-----------|
| Language | Java 17+ |
| Framework | Spring Boot 3.2 |
| Build tool | Gradle (multi-module) |
| DI | Spring (@Service, @RequiredArgsConstructor) |
| Web | Spring Web (controllers, ResponseEntity) |
| Persistence | JPA / Hibernate |
| Database | H2 (dev), PostgreSQL (prod) |
| Migrations | Liquibase |
| Mail | Spring Mail |
| Code generation | Lombok (@Data, @Builder, @Value, @RequiredArgsConstructor) |

## Frontend

| Concern | Technology |
|---------|-----------|
| Language | TypeScript |
| Framework | React 18 |
| Build tool | Vite |
| Test runner | Vitest |
| HTTP mocking | MSW (Mock Service Worker) |

## CSS

| Concern | Technology |
|---------|-----------|
| Framework | Tailwind CSS |
| Icons | lucide-react |

## Browser Testing

| Concern | Technology |
|---------|-----------|
| Framework | Selenium WebDriver |
| Async assertions | Awaitility |

## Testing (Backend)

| Concern | Technology |
|---------|-----------|
| Unit/integration | JUnit 5 |
| Assertions | AssertJ |
| Mocking | Mockito |
| Coverage | JaCoCo |
| Frontend tests | Vitest |

## Infrastructure

| Concern | Technology |
|---------|-----------|
| Containerization | Docker / docker-compose |
| Mail server (dev) | MailHog |

## Conventions

### Backend

| Concern | Convention |
|---------|-----------|
| Test disable marker | @Disabled |
| Not-implemented marker | throw UnsupportedOperationException() |
| Run command | ./gradlew :backend:application:bootRun |
| Test command | ./gradlew :backend:{module}:test |
| Acceptance test command | ./gradlew backendTest |
| Coverage report | JaCoCo XML in build/reports/jacoco/ |
| Health endpoint | /actuator/health |
| Spring config syntax | ${VAR:fallback} |
| Docker config syntax | ${VAR:-fallback} |

### Frontend

| Concern | Convention |
|---------|-----------|
| Test skip marker | .skip |
| Dev command | npm run dev |
| Test command | npx vitest run |
| Node config syntax | process.env.VAR \|\| 'fallback' |

### Browser Testing

| Concern | Convention |
|---------|-----------|
| Acceptance test command | ./gradlew frontendTest |
