# Server-side Cache with Cloudflare KV

Next.js `unstable_cache` caches the result of async functions (DB queries, external API calls, expensive computations) on the server. By default it uses the filesystem, which Cloudflare Workers don't have. Wire it to a KV namespace instead and you get a persistent, globally-replicated cache with no extra service.

This replaces Redis/Upstash for caching use cases. KV reads cost 4× less than Upstash at scale and have ~1ms latency since the store is co-located with the Worker. The trade-off: KV is eventually consistent and key-value only — no atomic operations, pub/sub, or sorted sets. For those, use Upstash. For caching, use KV.

## Setup

### 1. Create the KV namespace

```bash
npx wrangler kv namespace create NEXT_CACHE
# also create a preview namespace for local dev
npx wrangler kv namespace create NEXT_CACHE --preview
```

Copy the `id` values from the output.

### 2. Bind the namespace in `wrangler.jsonc`

```jsonc
{
  "name": "my-app",
  "compatibility_date": "2025-01-01",
  "compatibility_flags": ["nodejs_compat"],
  "kv_namespaces": [
    {
      "binding": "NEXT_CACHE_WORKERS_KV",
      "id": "<your-kv-namespace-id>",
      "preview_id": "<your-preview-namespace-id>"
    }
  ]
}
```

The binding name `NEXT_CACHE_WORKERS_KV` is required — `@opennextjs/cloudflare` looks for it by that exact name.

### 3. Enable the KV cache handler in `open-next.config.ts`

```ts
import type { OpenNextConfig } from "@opennextjs/cloudflare"

const config: OpenNextConfig = {
  default: {
    override: {
      wrapper: "cloudflare-node",
      incrementalCache: "cloudflare-kv",
    },
  },
}

export default config
```

## Using `unstable_cache`

Wrap any async function. The cache key is derived from the second argument (array of strings). Set `revalidate` for time-based expiry and `tags` for manual invalidation.

```ts
// src/lib/cache.ts
import { unstable_cache } from "next/cache"
import { db } from "@/lib/db"

// Cache for 60s; invalidate via revalidateTag("users")
export const getUser = unstable_cache(
  async (id: string) => db.users.findById(id),
  ["user"],
  { revalidate: 60, tags: ["users"] }
)

// Rarely changes — cache for 1 hour
export const getOrgConfig = unstable_cache(
  async (orgId: string) => db.orgs.getConfig(orgId),
  ["org-config"],
  { revalidate: 3600, tags: ["org-config"] }
)

// Public data shared across all users — cache aggressively
export const getPricingPlans = unstable_cache(
  async () => db.plans.findAll(),
  ["pricing-plans"],
  { revalidate: 86400, tags: ["plans"] }  // 24 hours
)
```

Call the cached function exactly like the original — Next.js handles the cache lookup transparently:

```ts
// src/app/dashboard/page.tsx
import { getUser, getOrgConfig } from "@/lib/cache"

export default async function DashboardPage() {
  const [user, config] = await Promise.all([
    getUser(userId),
    getOrgConfig(orgId),
  ])
  // ...
}
```

## Tag-based invalidation

Call `revalidateTag` after a mutation to purge all cache entries with that tag. This works across ISR pages and `unstable_cache` entries alike.

```ts
// src/app/actions/users.ts
"use server"
import { revalidateTag } from "next/cache"
import { db } from "@/lib/db"

export async function updateUser(id: string, data: Partial<User>) {
  await db.users.update(id, data)
  revalidateTag("users")  // purges every entry tagged "users" from KV
}

export async function deleteUser(id: string) {
  await db.users.delete(id)
  revalidateTag("users")
}
```

Tag multiple caches when a mutation touches several data domains:

```ts
export async function transferUserOrg(userId: string, newOrgId: string) {
  await db.users.updateOrg(userId, newOrgId)
  revalidateTag("users")
  revalidateTag("org-config")
}
```

## Layering with React Query

`unstable_cache` caches on the server (shared across all users, persisted in KV). React Query caches on the client (per-browser session, in memory). They complement each other:

- Server cache: DB hit on first request per TTL window, all users share the result
- Client cache: no fetch at all on repeat navigation within the same session

No special coordination is needed — server components use `unstable_cache`, client components use React Query as normal.

## What KV is not good for

Don't use KV (or `unstable_cache`) for:

- **Sessions**: use Supabase Auth or a strongly-consistent store; KV's eventual consistency can cause stale session reads
- **Rate limiting counters**: use the Cloudflare Workers Rate Limiting API (already in `checkRateLimit.ts`)
- **Real-time coordination**: use Durable Objects or Supabase Realtime
- **Short-lived per-request deduplication**: use React's `cache()` from `"react"` instead — it deduplicates within a single render pass without any network round-trip

## Pricing vs Upstash Redis

| | Cloudflare KV | Upstash Redis |
|---|---|---|
| Free reads | 100k/day (~3M/month) | 10k commands/day (~300k/month) |
| Free writes | 1k/day (~30k/month) | included in command count |
| Free storage | 1 GB | 256 MB |
| Paid base | $5/mo (Workers Paid plan) | $0 pay-as-you-go or $10/mo fixed |
| Read cost | $0.50/million | $2/million |
| Write cost | $5/million | $2/million |
| Storage | $0.50/GB-month | $0.25/GB-month |
| Consistency | Eventually consistent | Strongly consistent |
| Latency | ~1ms (co-located with Worker) | ~10–20ms (nearest region) |
| Data structures | Key-value only | Full Redis API |

For a cache-heavy app at 1M page views/month with a 70% cache hit rate: roughly **$0 extra** on KV (covered by the Workers Paid $5/mo base) vs ~**$14/mo** on Upstash. Use Upstash when you need Redis semantics; use KV when you need a cache.
