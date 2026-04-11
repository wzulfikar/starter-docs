# Safe Environment Variables

Never read from `process.env` directly in application code. Import a validated env object instead. This turns a runtime surprise ("undefined is not a valid API key") into a startup crash with a clear error message.

## The idea

`process.env` values are all `string | undefined`. TypeScript won't catch a missing key — the code compiles fine and blows up in production. A validated env module solves this in two ways:

1. **Startup validation** — missing required variables throw immediately when the process starts, not mid-request
2. **Typed access** — `env.OPENAI_API_KEY` is `string`, not `string | undefined`, so no casting or nullish coalescing needed downstream

```ts
// Without this pattern — silent failure
const apiKey = process.env.OPENAI_API_KEY // string | undefined — could be undefined
await openai.chat({ key: apiKey! })       // ! is a lie; blows up at runtime

// With this pattern — fail loud, fail early
import { env } from "@/env.server"
await openai.chat({ key: env.OPENAI_API_KEY }) // always a string
```

## Two files, two audiences

| File | Contains | Imported by |
|------|----------|-------------|
| `src/env.server.ts` | Server-only secrets (API keys, DB credentials) | Server code, route handlers, scripts |
| `src/env.ts` | Public vars safe to expose to the client | Both client and server code |

Never import `env.server` from client-side code. The build will include the secrets in the bundle.

## Simple approach — a validated object

Sufficient for most projects. Declare the expected keys, assert they exist at startup, export a typed object.

```ts
// src/env.server.ts

// Runtime flag — set this in CF dashboard or deployment platform
export const IS_CF_RUNTIME = !!process.env.IS_CF_RUNTIME

export const env = {
  DEVICE_TOKEN_SECRET: process.env.DEVICE_TOKEN_SECRET!,
  AUTUMN_SECRET_KEY: process.env.AUTUMN_SECRET_KEY!,
  DEEPGRAM_API_KEY: process.env.DEEPGRAM_API_KEY!,
  OPENAI_API_KEY: process.env.OPENAI_API_KEY!,
  PLUNK_API_KEY: process.env.PLUNK_API_KEY!,
  REVENUECAT_SECRET_KEY: process.env.REVENUECAT_SECRET_KEY!,
  REVENUECAT_PROJECT_ID: process.env.REVENUECAT_PROJECT_ID!,
  // Optional — absence is allowed
  DATAFAST_API_KEY: process.env.DATAFAST_API_KEY,
}

if (IS_CF_RUNTIME) {
  for (const key in env) {
    if (!env[key as keyof typeof env]) {
      throw new Error(`Missing environment variable: ${key}`)
    }
  }
}
```

The `IS_CF_RUNTIME` guard matters because Cloudflare Workers bind secrets differently from Node.js. During a local `next dev` run, `process.env` is populated from `.env`. In a deployed Worker, it isn't — variables come from the CF runtime bindings. The validation loop only runs where the platform actually provides bindings.

For a purely Node.js app (Vercel, Railway, etc.), skip the guard and run the loop unconditionally.

```ts
// src/env.server.ts — Node.js / Vercel variant
export const env = {
  DATABASE_URL: process.env.DATABASE_URL!,
  OPENAI_API_KEY: process.env.OPENAI_API_KEY!,
}

for (const key in env) {
  if (!env[key as keyof typeof env]) {
    throw new Error(`Missing environment variable: ${key}`)
  }
}
```

## Client env

Public variables (safe to ship to the browser) get their own file. In Next.js these are prefixed with `NEXT_PUBLIC_`.

```ts
// src/env.ts
export const env = {
  NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL!,
  NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL!,
}

for (const key in env) {
  if (!env[key as keyof typeof env]) {
    throw new Error(`Missing environment variable: ${key}`)
  }
}
```

## t3-env — when you want more strictness

[t3-env](https://env.t3.gg/docs/introduction) adds Zod-based schema validation, a hard client/server split enforced at the module level, and a `skipValidation` flag for CI environments where not all secrets are present.

```bash
bun add @t3-oss/env-nextjs zod
```

```ts
// src/env.ts
import { createEnv } from "@t3-oss/env-nextjs"
import { z } from "zod"

export const env = createEnv({
  server: {
    DATABASE_URL: z.string().url(),
    OPENAI_API_KEY: z.string().min(1),
    PLUNK_API_KEY: z.string().min(1),
  },
  client: {
    NEXT_PUBLIC_SUPABASE_URL: z.string().url(),
    NEXT_PUBLIC_SUPABASE_ANON_KEY: z.string().min(1),
  },
  // Map runtime values
  runtimeEnv: {
    DATABASE_URL: process.env.DATABASE_URL,
    OPENAI_API_KEY: process.env.OPENAI_API_KEY,
    PLUNK_API_KEY: process.env.PLUNK_API_KEY,
    NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
    NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  },
})
```

t3-env is worth it when:
- You have many optional variables that need coercion (URL, number, boolean)
- You want Zod transforms at the boundary (e.g. `z.string().url()` for database URLs)
- You want to document which vars are client-safe vs. server-only in one schema

For straightforward projects, the simple loop is less setup and sufficient.

## Usage

```ts
// In a route handler or server action
import { env } from "@/env.server"

export async function POST(req: Request) {
  const client = new OpenAI({ apiKey: env.OPENAI_API_KEY })
  // ...
}

// In a component or shared utility
import { env } from "@/env"

const supabase = createClient(env.NEXT_PUBLIC_SUPABASE_URL, env.NEXT_PUBLIC_SUPABASE_ANON_KEY)
```

## What not to do

```ts
// Don't scatter process.env reads through the codebase
const res = await fetch("...", {
  headers: { Authorization: `Bearer ${process.env.OPENAI_API_KEY}` }, // undefined in prod?
})

// Don't check for undefined at call sites — that's the env module's job
if (!process.env.OPENAI_API_KEY) throw new Error("...")
const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY })
```

Put the validation in one place, trust it everywhere else.
