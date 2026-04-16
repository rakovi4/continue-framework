# Controller Test Template -- PHP/Laravel

> Universal rules: `.claude/templates/tdd/red-rest.md`

## Tech-Specific Rules

- Extend Laravel `TestCase` with `$this->getJson()`, `$this->postJson()`, etc.
- Mock use-case dependencies with `Mockery::mock()` or `$this->mock()`
- Create exactly ONE test method, add `$this->markTestSkipped('RED: ...')`
- Add `#[TestDox('...')]` with Gherkin-style description
- Setup: `$this->mock(UsecaseClass::class)->shouldReceive('execute')->andReturn(...)`
- Execute: `$this->getJson('/api/...')` or `$this->postJson('/api/...', $data)`
- Verify: `$response->assertJson($expected)` or `$response->assertExactJson($expected)`

## Expected Response JSON

Create in `backend/adapters/rest/tests/Fixtures/{Feature}/` or inline as arrays for small responses.

## Reference (read before generating)

- Test example: `backend/adapters/rest/tests/Controller/{Feature}/{Feature}ControllerTest.php`
- Test setup: `backend/adapters/rest/tests/TestCase.php`
- Request DTO example: `backend/adapters/rest/src/Dto/{Feature}/{Feature}RequestDto.php`
- JSON fixture example: `backend/adapters/rest/tests/Fixtures/` (look for existing JSON files)

## Key Paths

- Tests: `backend/adapters/rest/tests/Controller/`
- Production: `backend/adapters/rest/src/Controller/`
- DTOs: `backend/adapters/rest/src/Dto/`
- Fixtures: `backend/adapters/rest/tests/Fixtures/`
