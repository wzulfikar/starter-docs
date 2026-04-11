# Thin API Wrapper with ky

When you need a few endpoints from a service — especially one without an SDK — don't install a heavy client library or write raw `fetch` calls. Create a thin wrapper with `ky`.

## Why ky over fetch

- Automatic JSON parsing
- Throws on non-2xx by default (no manual `if (!res.ok)`)
- `beforeRequest` / `afterResponse` hooks for auth, logging, and retries
- Clean, chainable API that types well with TypeScript

## The pattern

Create one file per service in `src/lib/<service>.ts`. Only implement the methods you actually call. Naming follows the service's own terminology.

```ts
// src/lib/resend.ts
import ky from "ky"

const resend = ky.create({
  prefixUrl: "https://api.resend.com",
  headers: {
    Authorization: `Bearer ${process.env.RESEND_API_KEY}`,
  },
})

export type SendEmailParams = {
  from: string
  to: string | string[]
  subject: string
  html: string
}

export async function sendEmail(params: SendEmailParams) {
  return resend.post("emails", { json: params }).json<{ id: string }>()
}
```

That's the whole wrapper — one `ky.create` instance, one exported function per endpoint used.

## Dynamic auth with beforeRequest hooks

When the token isn't static (OAuth access tokens, short-lived JWTs, HMAC signatures), use the `beforeRequest` hook to inject auth at call time:

```ts
// src/lib/some-service.ts
import ky, { type BeforeRequestHook } from "ky"
import { getAccessToken } from "@/lib/auth"

const injectAuth: BeforeRequestHook = async (request) => {
  const token = await getAccessToken() // fetch/refresh as needed
  request.headers.set("Authorization", `Bearer ${token}`)
}

const client = ky.create({
  prefixUrl: "https://api.some-service.com/v1",
  hooks: {
    beforeRequest: [injectAuth],
  },
})

export async function listItems() {
  return client.get("items").json<{ items: Item[] }>()
}

export async function createItem(data: NewItem) {
  return client.post("items", { json: data }).json<Item>()
}
```

The hook runs before every request, so token rotation is handled automatically without touching call sites.

## Multiple auth strategies

```ts
// API key in header
const injectApiKey: BeforeRequestHook = (request) => {
  request.headers.set("X-Api-Key", process.env.SERVICE_API_KEY!)
}

// HMAC signature per request
const injectHmac: BeforeRequestHook = async (request) => {
  const body = await request.clone().text()
  const sig = await hmacSign(body, process.env.SERVICE_SECRET!)
  request.headers.set("X-Signature", sig)
}

// Tenant-scoped token from context
const injectTenantToken: BeforeRequestHook = async (request) => {
  const { tenantId } = getRequestContext()
  const token = await getTenantToken(tenantId)
  request.headers.set("Authorization", `Bearer ${token}`)
}
```

## Error handling

ky throws `HTTPError` on non-2xx. Unwrap the response body for structured errors from the service:

```ts
import ky, { HTTPError } from "ky"

export async function createItem(data: NewItem) {
  try {
    return await client.post("items", { json: data }).json<Item>()
  } catch (err) {
    if (err instanceof HTTPError) {
      const body = await err.response.json<{ message: string }>()
      throw new Error(`Service error: ${body.message}`)
    }
    throw err
  }
}
```

## When not to use this pattern

- The service has a well-maintained SDK that covers your use case — use the SDK
- You need more than ~5–6 endpoints — at that point an SDK or generated client (e.g. from OpenAPI) is worth the setup cost
- The service requires complex request signing or pagination that a thin wrapper will recreate poorly

## File structure

```
src/
  lib/
    resend.ts        # email
    stripe.ts        # payments (thin wrapper, not stripe-js)
    linear.ts        # issue tracking
    some-service.ts  # anything without an SDK
```

One file per service. Import directly from the file, not through a barrel export — keeps tree-shaking clean on the server bundle.
