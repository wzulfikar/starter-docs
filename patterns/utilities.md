# Essential Utilities

Small, focused packages that handle common problems well. Each one does one thing and composes cleanly with the rest of your stack.

## p-queue

Limits how many async operations run at the same time. Useful when you're processing a list of items and can't fire them all in parallel — rate-limited APIs, database writes under load, bulk file processing.

```ts
import PQueue from "p-queue"

const queue = new PQueue({ concurrency: 3 })

const results = await Promise.all(
  userIds.map((id) => queue.add(() => fetchUser(id)))
)
```

The `concurrency` option caps simultaneous in-flight tasks. Tasks beyond the limit are queued and started automatically as slots free up.

**Control flow options:**

```ts
// Wait until the queue drains before continuing
await queue.onIdle()

// Pause and resume (e.g. when a rate limit is hit)
queue.pause()
await sleep(1000)
queue.start()

// Inspect state
console.log(queue.size)    // waiting
console.log(queue.pending) // running
```

**Related utilities from the same family:**

- **p-limit** — simpler version if you only need a concurrency cap with no queue management:
  ```ts
  import pLimit from "p-limit"
  const limit = pLimit(3)
  const results = await Promise.all(items.map((item) => limit(() => process(item))))
  ```

- **p-retry** — retry a failing async operation with exponential backoff:
  ```ts
  import pRetry from "p-retry"
  const data = await pRetry(() => fetchFromUnreliableApi(), { retries: 4 })
  ```

Use `p-queue` when you need a full queue with pause/resume and drain events. Use `p-limit` for a lightweight concurrency cap. Use `p-retry` when you need automatic retries on failure.

## date-fns

A modular date utility library. Each function is a pure, tree-shakeable import — no bloated class instances, no global state.

**Formatting:**

```ts
import { format, formatDistanceToNow } from "date-fns"

format(new Date(), "MMM d, yyyy")         // "Apr 11, 2026"
format(new Date(), "HH:mm")              // "14:32"
formatDistanceToNow(new Date(post.publishedAt), { addSuffix: true })
// "3 days ago"
```

**Arithmetic:**

```ts
import { addDays, subMonths, startOfWeek, endOfMonth } from "date-fns"

const nextWeek = addDays(new Date(), 7)
const lastMonth = subMonths(new Date(), 1)
const weekStart = startOfWeek(new Date(), { weekStartsOn: 1 }) // Monday
```

**Comparison and validation:**

```ts
import { isBefore, isAfter, isValid, parseISO } from "date-fns"

const date = parseISO(input) // parse ISO 8601 strings safely
if (!isValid(date)) throw new Error("Invalid date")

isBefore(date, new Date()) // true if date is in the past
```

**Timezones:** Use `date-fns-tz` alongside `date-fns` when you need timezone-aware formatting or conversion:

```ts
import { formatInTimeZone } from "date-fns-tz"

formatInTimeZone(new Date(), "America/New_York", "MMM d, yyyy HH:mm zzz")
// "Apr 11, 2026 10:32 EDT"
```

## nuqs

Synchronises React state with URL search params. The URL becomes the source of truth — filters, pagination, tabs, and other UI state survive page refreshes and are shareable as links.

**Basic usage:**

```ts
import { useQueryState } from "nuqs"

export function SearchBar() {
  const [query, setQuery] = useQueryState("q")

  return (
    <input
      value={query ?? ""}
      onChange={(e) => setQuery(e.target.value || null)}
      placeholder="Search..."
    />
  )
}
// URL: /products?q=shoes
```

**Typed params with parsers:**

```ts
import { useQueryState, parseAsInteger, parseAsStringEnum } from "nuqs"

const [page, setPage] = useQueryState("page", parseAsInteger.withDefault(1))
const [sort, setSort] = useQueryState(
  "sort",
  parseAsStringEnum(["asc", "desc"]).withDefault("desc")
)
```

**Multiple params at once with `useQueryStates`:**

```ts
import { useQueryStates, parseAsInteger, parseAsString } from "nuqs"

const [filters, setFilters] = useQueryStates({
  q:      parseAsString.withDefault(""),
  page:   parseAsInteger.withDefault(1),
  status: parseAsString.withDefault("all"),
})

// Update multiple params in one push (single history entry)
setFilters({ page: 1, status: "active" })
```

**Next.js App Router setup** — wrap your layout with the nuqs adapter:

```tsx
// app/layout.tsx
import { NuqsAdapter } from "nuqs/adapters/next/app"

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        <NuqsAdapter>{children}</NuqsAdapter>
      </body>
    </html>
  )
}
```

nuqs supports Next.js (App Router and Pages), React Router, and Remix. Pick the matching adapter — the `useQueryState` API is identical across all of them.
