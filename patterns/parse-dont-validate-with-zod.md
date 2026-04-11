# Parse, Don't Validate with Zod

Parse untrusted input at layer boundaries and let it flow as trusted, typed data everywhere after. Never validate the same input twice, and never carry unvalidated data past the boundary where it enters.

## The idea

**Validation** checks whether data is correct and returns a boolean.
**Parsing** checks whether data is correct and returns it in the right shape — or throws.

The difference is that after parsing, the type system carries the proof. You don't need to re-check or re-cast downstream. Code inside the boundary can safely assume the data is what it claims to be.

```ts
// Validation: you still have `unknown`, nothing has changed
function isValidUser(data: unknown): boolean {
  return typeof data === "object" && data !== null && "id" in data
}

// Parsing: you get back a typed value, or an error — no in-between
const user = UserSchema.parse(data) // User — or throws ZodError
```

## Boundaries

Parse at every point where data crosses from untrusted to trusted:

| Boundary | Untrusted source | Parse with |
|----------|-----------------|------------|
| Route handler | HTTP request body / query params | `zod` |
| Command args | `process.argv` / CLI flags | `zod-opts` |
| External API response | Third-party JSON | `zod` |
| Environment variables | `process.env` | `@t3-oss/env-nextjs` or `zod` |

## Route handler boundary

Parse the request body at the top of the handler. Everything below it works with typed data.

```ts
import { z } from "zod"
import { NextRequest, NextResponse } from "next/server"

const CreatePostSchema = z.object({
  title: z.string().min(1).max(200),
  body: z.string().min(1),
  tags: z.array(z.string()).optional().default([]),
})

export async function POST(req: NextRequest) {
  const json = await req.json()
  const input = CreatePostSchema.parse(json) // throws ZodError if invalid

  // From here: input.title, input.body, input.tags are fully typed
  // No need to check for undefined or cast anything
  const post = await db.posts.create({ data: input })
  return NextResponse.json(post)
}
```

Return a clean error response instead of letting ZodError bubble:

```ts
import { z, ZodError } from "zod"

export async function POST(req: NextRequest) {
  try {
    const input = CreatePostSchema.parse(await req.json())
    const post = await db.posts.create({ data: input })
    return NextResponse.json(post)
  } catch (err) {
    if (err instanceof ZodError) {
      return NextResponse.json({ error: err.flatten() }, { status: 400 })
    }
    throw err
  }
}
```

## Command args boundary

Use `zod-opts` for CLI scripts. Same Zod schemas, no manual `process.argv` parsing.

```ts
// commands/send-email.ts
import { z } from "zod"
import { parser } from "zod-opts"

async function main() {
  const args = parser()
    .options({
      to: { type: z.string().email() },
      subject: { type: z.string().min(1) },
      dry: { type: z.boolean().default(false) },
    })
    .parse()

  // args.to, args.subject, args.dry — typed, validated, with defaults applied
  if (args.dry) {
    console.log("Dry run:", args)
    return
  }
  await sendEmail({ to: args.to, subject: args.subject })
}

main()
```

Run with:
```bash
bun commands/send-email.ts --to user@example.com --subject "Hello"
bun commands/send-email.ts --to user@example.com --subject "Hello" --dry
```

`zod-opts` generates `--help` output automatically from the schema.

## Coercion and transformation at the boundary

The boundary is also the right place to coerce and normalise — not deeper in the code.

```ts
const QuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),   // "2" → 2
  limit: z.coerce.number().int().max(100).default(20),
  search: z.string().trim().toLowerCase().optional(),     // " Hello " → "hello"
  status: z.enum(["active", "archived"]).default("active"),
})
```

After parsing, `page` is a `number`, not a `string`. You never write `Number(params.page)` inside a handler.

## Safe assumption inside the boundary

Once input is parsed, treat it as trusted. Don't add defensive checks for things the schema already guarantees:

```ts
// After parsing with z.string().min(1) — don't do this:
if (!input.title || input.title.length === 0) { ... }

// The schema already made this impossible. Trust it.
await db.posts.create({ data: { title: input.title } })
```

Adding redundant checks after parsing defeats the purpose — it suggests the schema isn't trusted, which leads to defensive code noise throughout the codebase.

## External API responses

Parse third-party responses at the call site, not inside callers:

```ts
// src/lib/github.ts
const RepoSchema = z.object({
  id: z.number(),
  full_name: z.string(),
  stargazers_count: z.number(),
  private: z.boolean(),
})

export async function getRepo(owner: string, name: string) {
  const data = await github.get(`repos/${owner}/${name}`).json()
  return RepoSchema.parse(data) // callers get a typed Repo, not unknown
}
```

If the external API changes shape, the parse throws at the boundary — not somewhere deep in the UI where a missing field causes a confusing crash.
