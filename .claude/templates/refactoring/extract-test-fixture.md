# Extract Test Fixture

When to use: MSW API test functions exceed 10 lines due to inline response objects, handler setup boilerplate, or repeated request verification logic.

## Extract Response Fixture
```typescript
// Before — inline response object bloats the test
it('should return task details', async () => {
  server.use(
    http.get(`${BASE}/api/v1/tasks/1`, () => {
      return HttpResponse.json({
        id: '1',
        title: 'Fix login bug',
        status: 'in_progress',
        column_id: 'col-2',
        created_at: '2026-01-20T10:00:00Z',
      })
    })
  )
  const response = await getTaskDetails('1')
  expect(response.id).toBe('1')
  expect(response.title).toBe('Fix login bug')
  // ... 3 more field assertions
})

// After — fixture as constant, toEqual for pass-through
const TASK_DETAILS = {
  id: '1',
  title: 'Fix login bug',
  status: 'in_progress',
  column_id: 'col-2',
  created_at: '2026-01-20T10:00:00Z',
}

it('should return task details', async () => {
  stubGet('/api/v1/tasks/1', TASK_DETAILS)
  const response = await getTaskDetails('1')
  expect(response).toEqual(TASK_DETAILS)
})
```

## Extract Stub Helper
```typescript
// Before — server.use + http.method + BASE URL repeated per test
server.use(
  http.get(`${BASE}/api/v1/tasks/1`, () => HttpResponse.json(body))
)

// After — one-line stub call
function stubGet(path: string, body: object) {
  server.use(http.get(`${BASE}${path}`, () => HttpResponse.json(body)))
}
```

## Extract Request Verification (void endpoints)

For endpoints that return no body (204), verify the request was actually sent with correct method, path, and credentials.

```typescript
// Before — inline capture + 4 assertions = 13 lines
it.skip('should send DELETE', async () => {
  server.use(http.delete(`${BASE}/api/v1/tasks/1`, () => new HttpResponse(null, { status: 204 })))
  const requests: Request[] = []
  server.events.on('request:match', ({ request }) => { requests.push(request) })

  await deleteTask('1')

  expect(requests).toHaveLength(1)
  expect(requests[0].method).toBe('DELETE')
  expect(new URL(requests[0].url).pathname).toBe('/api/v1/tasks/1')
  expect(requests[0].credentials).toBe('include')
})

// After — extracted helpers, 5 lines
function captureRequests(): Request[] {
  const requests: Request[] = []
  server.events.on('request:match', ({ request }) => { requests.push(request) })
  return requests
}

function assertRequest(requests: Request[], method: string, path: string) {
  expect(requests).toHaveLength(1)
  expect(requests[0].method).toBe(method)
  expect(new URL(requests[0].url).pathname).toBe(path)
  expect(requests[0].credentials).toBe('include')
}

it.skip('should send DELETE', async () => {
  server.use(http.delete(`${BASE}/api/v1/tasks/1`, () => new HttpResponse(null, { status: 204 })))
  const requests = captureRequests()
  await deleteTask('1')
  assertRequest(requests, 'DELETE', '/api/v1/tasks/1')
})
```

## When to use toEqual vs individual assertions

- **toEqual(FIXTURE)**: when the API client passes JSON through unchanged (GET endpoints). The fixture IS the expected value.
- **Individual assertions**: when the client transforms data (e.g., `getPlans` extracts `.plans` from wrapper object).
