# Normalize API Errors with ky

When calling external APIs, two distinct error types can occur. They have different audiences and must be handled differently:

| Error | Class | Audience | Action |
|---|---|---|---|
| Non-2xx response | `HTTPError` | User | Show message based on status |
| Schema mismatch | `SchemaValidationError` | Developer | Report to error tracker, fix immediately |

The user can act on an HTTP error (wrong credentials, resource not found, rate limited). They can't act on a schema mismatch — the API changed shape, and you need to fix the code. From the user's perspective it's just "something went wrong", but your error tracker must surface it with full detail so you find it immediately.

## Normalizing HTTP errors at the instance level

Use the `beforeError` hook on the ky instance to convert `HTTPError` into your own `APIResultError`. Every request on the instance gets this automatically — no wrapper, no per-call try/catch.

```ts
// src/lib/api.ts
import ky, { HTTPError } from "ky"

export class APIResultError extends Error {
  constructor(
    public readonly status: number,
    public readonly body: unknown
  ) {
    super(`API error: ${status}`)
    this.name = "APIResultError"
  }
}

export const api = ky.create({
  prefixUrl: "https://api.example.com",
  hooks: {
    beforeError: [
      (error) => {
        throw new APIResultError(error.response.status, error.data)
      },
    ],
  },
})
```

`error.data` is already parsed by ky — no need to call `error.response.json()`.

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
  // return type: z.infer<typeof RepoSchema> — derived from schema, not asserted
}
```

Call sites stay clean. No try/catch, no wrapper function.

## Wiring to the global error handler

The two error types must be handled in the global error handler. This is the only place `SchemaValidationError` needs to be caught:

```ts
// src/lib/on-error.ts
import { SchemaValidationError } from "ky"
import { APIResultError } from "@/lib/api"

export function onError(err: unknown) {
  if (err instanceof APIResultError) {
    // User-facing: map status to message
    if (err.status === 401) return "Not authenticated"
    if (err.status === 403) return "Not allowed"
    if (err.status === 404) return "Not found"
    if (err.status === 429) return "Too many requests, try again later"
    return "Something went wrong"
  }

  if (err instanceof SchemaValidationError) {
    // Dev-facing: report with full detail, show generic message to user
    reportToErrorTracker(err, { issues: err.issues })
    return "Something went wrong"
  }

  // Unknown — rethrow or report
  throw err
}
```

`SchemaValidationError` intentionally does not extend `KyError` — ky itself draws the boundary between HTTP concerns and data concerns. The global handler mirrors that same boundary.

## Why not normalize SchemaValidationError into APIResultError

`SchemaValidationError` bypasses the `beforeError` hook because it is not an HTTP error — it is thrown after the response is received and parsed, during schema validation. There is no ky hook that intercepts it, which reflects its nature: it is a code problem, not a network problem. Treating it differently in the error handler makes that distinction explicit.

## File structure

```
src/
  lib/
    api.ts        # ky instance with beforeError hook, APIResultError class
    on-error.ts   # global error handler, handles APIResultError + SchemaValidationError
    github.ts     # uses api instance, .json(Schema) for typed + validated responses
    resend.ts     # same pattern
```
