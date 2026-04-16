# Backend Endpoint Pre-Check

Before writing any frontend API client test, verify the backend endpoint exists:

1. Determine the HTTP method and path the frontend API function will call
2. Search `backend/adapters/rest/` for a controller mapping that matches the method and path (consult the backend tech profile for annotation/decorator syntax)
3. If NO match -- **STOP**. Report the missing endpoint and ask the user to add a backend scenario first. Do NOT write the test.
