# Normalize API Errors with ky

When calling external APIs, errors need to be normalized into consistent types so the global error handler can respond correctly without coupling to ky internals.

## Normalizing HTTP errors at the instance level

Use the `beforeError` hook on the ky instance to convert `HTTPError` into your own `APINetworkError`. Every request on the instance gets this automatically: no wrapper, no per-call try/catch.

```ts
// src/lib/api.ts
import ky from "ky"

export class APINetworkError extends Error {
  constructor(
    public readonly status: number,
    public readonly body: unknown
  ) {
    super(`Network error: ${status}`)
    this.name = "APINetworkError"
  }
}

export const api = ky.create({
  prefixUrl: "https://api.example.com",
  hooks: {
    beforeError: [
      (error) => {
        throw new APINetworkError(error.response.status, error.data)
      },
    ],
  },
})
```

`error.data` is already parsed by ky, so no need to call `error.response.json()`.

## Schema validation with ky's built-in support

ky natively accepts a Zod schema in `.json(schema)` and throws `SchemaValidationError` if the response doesn't match. No separate parsing step needed:

```ts
// src/lib/github.ts
import { z } from "zod"
import { api } from "@/lib/api"

const RepoSchema = z.object({
  id: z.number(),
  full_name: z.string(),
  stargazers_count: z.number(),
  private: z.boolean(),
})

export async function getRepo(owner: string, name: string) {
  return api.get(`repos/${owner}/${name}`).json(RepoSchema)
  // return type: z.infer<typeof RepoSchema>, derived from schema, not asserted
}
```

Call sites stay clean. No try/catch, no wrapper function.

## The Three Errors at API Boundary

Every error that can occur when calling an external API falls into one of three categories. Each has a different cause, a different audience, and a different handling strategy:

| Error | Class | Cause | User sees | Dev action |
|---|---|---|---|---|
| `APINetworkError` | `HTTPError` + `TypeError` | HTTP layer: 4xx, 5xx, timeout, DNS failure | Actionable message (401 → "log in", 429 → "slow down") | Usually none, it's expected |
| `APIBusinessError` | Custom | API logic: quota exceeded, already exists, invalid input | Specific message from the API | Usually none, handle in UI |
| `APIResultError` | `SchemaValidationError` | Response shape changed unexpectedly | "Something went wrong" | Fix immediately, API drifted |

**`APINetworkError`**: the transport layer failed or the server rejected the request. The user may have caused it (wrong credentials, rate limited) or it's transient (timeout, server down). Either way it's expected and recoverable.

**`APIBusinessError`**: the request succeeded at the HTTP level but the API returned a documented error; quota exceeded, resource already exists, validation failed. The API contract defines these explicitly. The user can act on them.

**`APIResultError`**: the request succeeded and the API returned 2xx, but the response shape doesn't match the schema. This is never expected. The API changed without notice, or the schema is wrong. The user can't act on it; you need to fix the code and report it to the error tracker immediately.

Note: `APINetworkError` has two sub-flavours with slightly different behaviour in ky. HTTP errors (4xx/5xx) are caught by `beforeError`, while true network errors (timeout, DNS, connection refused) are thrown as `TypeError` and bypass `beforeError`. Both mean the transport layer failed and are usually handled the same way, but timeout vs 401 may need different user messages.

## Handling business errors

When an API uses 200 for everything (envelope pattern), use a discriminated union schema and unwrap it in the wrapper function:

```ts
// src/lib/github.ts
export class APIBusinessError extends Error {
  constructor(
    public readonly code: string,
    message: string
  ) {
    super(message)
    this.name = "APIBusinessError"
  }
}

const RepoResponseSchema = z.discriminatedUnion("ok", [
  z.object({ ok: z.literal(true), data: RepoSchema }),
  z.object({ ok: z.literal(false), code: z.string(), message: z.string() }),
])

export async function getRepo(owner: string, name: string) {
  const result = await api.get(`repos/${owner}/${name}`).json(RepoResponseSchema)
  if (!result.ok) throw new APIBusinessError(result.code, result.message)
  return result.data  // typed as z.infer<typeof RepoSchema>
}
```

Callers get clean typed data. `APIBusinessError` surfaces in the global handler with enough detail to show a specific message.

## Wiring to the global error handler

All three error types converge in the global error handler. `SchemaValidationError` (ky's own class for shape mismatches) is the only place where a ky class surfaces; everything else is your own:

```ts
// src/lib/on-error.ts
import { SchemaValidationError } from "ky"
import { APINetworkError, APIBusinessError } from "@/lib/api"

export function onError(err: unknown) {
  if (err instanceof APINetworkError) {
    // User-facing: map status to message
    if (err.status === 401) return "Not authenticated"
    if (err.status === 403) return "Not allowed"
    if (err.status === 404) return "Not found"
    if (err.status === 429) return "Too many requests, try again later"
    return "Something went wrong"
  }

  if (err instanceof APIBusinessError) {
    // User-facing: specific message from the API
    return err.message
  }

  if (err instanceof SchemaValidationError) {
    // Dev-facing: report with full detail, show generic message to user
    reportToErrorTracker(err, { issues: err.issues })
    return "Something went wrong"
  }

  throw err
}
```

`SchemaValidationError` intentionally does not extend `KyError`. ky itself draws the boundary between HTTP concerns and data concerns. It bypasses the `beforeError` hook because it is thrown after the response is received and parsed, during schema validation. The global handler is the only place it needs to be caught.

## File structure

```
src/
  lib/
    api.ts        # ky instance with beforeError hook, APINetworkError + APIBusinessError classes
    on-error.ts   # global error handler: APINetworkError, APIBusinessError, SchemaValidationError
    github.ts     # uses api instance, .json(Schema) for typed + validated responses
    resend.ts     # same pattern
```
