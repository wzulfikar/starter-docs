# Parse API Result

When calling external APIs with ky, don't use `.json<T>()` to type the response. It's a blind cast — TypeScript believes you but nothing checks it. Use `parseAPIResult` instead: it validates the response against a Zod schema and returns a type derived from the schema, not asserted by you.

## Why

| | `.json<T>()` | `parseAPIResult` |
|---|---|---|
| Return type | Manual cast, no guarantee | Derived from schema via `z.infer<T>` |
| Schema drift | Silent wrong data | Throws immediately at the boundary |
| Error handling | Leaks `HTTPError` from ky | Wraps in `APIResultError` |
| Boundary signal | None | Explicit — this is where external data enters |

The global error handler only needs to know about `APIResultError`, not ky internals. If you swap ky later, nothing upstream changes.

## Implementation

```ts
// src/lib/parse-api-result.ts
import { HTTPError } from "ky"
import { ZodError, type ZodSchema, type z } from "zod"

type Ok<T> = { ok: true; data: T }
type Err = { ok: false; error: APIResultError }
export type APIResult<T> = Ok<T> | Err

export class APIResultError extends Error {
  constructor(
    public readonly kind: "network" | "invalid_shape",
    public readonly details?: unknown
  ) {
    super(`API result error: ${kind}`)
    this.name = "APIResultError"
  }
}

export async function parseAPIResult<T extends ZodSchema>(
  schema: T,
  response: Promise<unknown>,
  options?: { throwOnError?: true }
): Promise<z.infer<T>>
export async function parseAPIResult<T extends ZodSchema>(
  schema: T,
  response: Promise<unknown>,
  options: { throwOnError: false }
): Promise<APIResult<z.infer<T>>>
export async function parseAPIResult<T extends ZodSchema>(
  schema: T,
  response: Promise<unknown>,
  options?: { throwOnError?: boolean }
): Promise<z.infer<T> | APIResult<z.infer<T>>> {
  const throwOnError = options?.throwOnError ?? true

  let error: APIResultError

  try {
    const data = await response
    const parsed = schema.parse(data)
    return throwOnError ? parsed : { ok: true, data: parsed }
  } catch (err) {
    if (err instanceof ZodError) {
      error = new APIResultError("invalid_shape", err.flatten())
    } else if (err instanceof HTTPError) {
      error = new APIResultError("network", err.response.status)
    } else {
      throw err // unexpected — not our problem
    }
  }

  if (throwOnError) throw error
  return { ok: false, error }
}
```

## Usage

In a ky wrapper, pass the `.json()` promise directly. The wrapper becomes a one-liner:

```ts
// src/lib/github.ts
import ky from "ky"
import { z } from "zod"
import { parseAPIResult } from "@/lib/parse-api-result"

const github = ky.create({ prefixUrl: "https://api.github.com" })

const RepoSchema = z.object({
  id: z.number(),
  full_name: z.string(),
  stargazers_count: z.number(),
  private: z.boolean(),
})

export async function getRepo(owner: string, name: string) {
  return parseAPIResult(RepoSchema, github.get(`repos/${owner}/${name}`).json())
  // return type: { id: number; full_name: string; stargazers_count: number; private: boolean }
}
```

## Opting out of throwing

By default `parseAPIResult` throws `APIResultError`. Pass `{ throwOnError: false }` to get a result container instead — useful when the caller needs to branch on failure rather than delegate to the global handler:

```ts
const result = await parseAPIResult(RepoSchema, github.get("repos/owner/name").json(), {
  throwOnError: false,
})

if (result.ok) {
  console.log(result.data.full_name)
} else {
  console.error(result.error.kind, result.error.details)
}
```

Unexpected errors (non-ky, non-Zod) always rethrow regardless of `throwOnError` — those belong to the global handler, not the caller.

## Global error handler

```ts
if (err instanceof APIResultError) {
  if (err.kind === "network") {
    // HTTP error — err.details is the status code
  }
  if (err.kind === "invalid_shape") {
    // Schema mismatch — err.details is ZodError.flatten() output
  }
}
```

## File location

```
src/
  lib/
    parse-api-result.ts   # APIResultError class + parseAPIResult function
    github.ts             # uses parseAPIResult
    resend.ts             # uses parseAPIResult
```
