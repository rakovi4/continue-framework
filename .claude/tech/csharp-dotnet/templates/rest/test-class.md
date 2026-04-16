# Controller Test Template -- C#/ASP.NET Core

> Universal rules: `.claude/templates/tdd/red-rest.md`

## Tech-Specific Rules

- Use `WebApplicationFactory<Program>` with `HttpClient` from test server
- Mock use-case dependencies with `Moq` (`Mock<IUsecase>`) or `NSubstitute`
- Create exactly ONE test method, add `[Fact(Skip = "RED: ...")]`
- Add `[Trait("Description", "Gherkin-style scenario")]` for scenario documentation
- Setup: `mockUsecase.Setup(x => x.Execute(It.IsAny<Request>())).ReturnsAsync(response)`
- Execute: `var response = await client.GetAsync("/api/...")`
- Verify: `var body = await response.Content.ReadFromJsonAsync<ResponseDto>(); body.Should().BeEquivalentTo(expected)`

## Expected Response JSON

Create in `backend/Adapters/Rest.Tests/Fixtures/{Feature}/` or inline as anonymous objects for small responses.

## Reference (read before generating)

- Test example: `backend/Adapters/Rest.Tests/Controller/{Feature}/{Feature}ControllerTest.cs`
- Test setup: `backend/Adapters/Rest.Tests/TestFixture.cs`
- Request DTO example: `backend/Adapters/Rest/Dto/{Feature}/{Feature}RequestDto.cs`
- JSON fixture example: `backend/Adapters/Rest.Tests/Fixtures/` (look for existing JSON files)

## Key Paths

- Tests: `backend/Adapters/Rest.Tests/Controller/`
- Production: `backend/Adapters/Rest/Controller/`
- DTOs: `backend/Adapters/Rest/Dto/`
- Fixtures: `backend/Adapters/Rest.Tests/Fixtures/`
