# Extract Test Base Class

**When to use:** 2+ sibling test classes sharing a base class duplicate fields (`@Autowired` dependencies), `@BeforeEach` setup, or helper methods (stubs, assertions). Pull up the shared code.

## Before

```java
class UserAuthTest implements ApiClientTest {
    @RegisterExtension
    static WireMockExtension wireMock = WireMockExtension.newInstance()
        .options(wireMockConfig().dynamicPort()).build();

    private HttpApiClient client;

    @BeforeEach
    void setUp() {
        client = new HttpApiClient(wireMock.baseUrl());
    }
}

class OrderFetchTest implements ApiClientTest {
    @RegisterExtension
    static WireMockExtension wireMock = ...;  // DUPLICATE
}
```

## After

```java
abstract class AbstractApiClientTest implements ApiClientTest {
    @RegisterExtension
    static WireMockExtension wireMock = WireMockExtension.newInstance()
        .options(wireMockConfig().dynamicPort()).build();

    protected HttpApiClient client;

    @BeforeEach
    void setUp() {
        client = new HttpApiClient(wireMock.baseUrl());
    }

    protected void stubSuccessResponse(String token) { ... }
}

class UserAuthTest extends AbstractApiClientTest { ... }
class OrderFetchTest extends AbstractApiClientTest { ... }
```

## Steps

1. Find candidates — test classes implementing same marker interface
2. List shared code — `@RegisterExtension`, `@BeforeEach`, helpers
3. Create `abstract class Abstract{MarkerInterface}Test`
4. Move setup — fields to `protected`, methods to base class
5. Update subclasses — `extends AbstractXxxTest`, remove duplicates
6. Run tests

## Visibility

| Element | Visibility |
|---------|------------|
| Base class | package-private |
| Static fields | `protected static` |
| Instance fields | `protected` |
| Helper methods | `protected` |
