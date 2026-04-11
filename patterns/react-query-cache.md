# React Query Cache Pattern

The goal is instant-feeling navigation. Data loads once, gets cached, and subsequent views show immediately from cache while React Query quietly refreshes in the background.

## The rules

1. **Show a loading indicator only on first load** — when there is no cached data yet
2. **On subsequent visits show cached data immediately** — no spinner, no layout shift. Stale data is fine; React Query refetches in the background and updates the UI if the new data differs
3. **Clear the cache on logout** — so the next user session starts fresh

## QueryClient setup

Configure `staleTime` globally so data isn't immediately considered stale after fetching:

```ts
// src/lib/query-client.ts
import { QueryClient } from "@tanstack/react-query"

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30 * 1000,        // data stays fresh for 30s
      gcTime: 5 * 60 * 1000,       // cache kept in memory for 5 min after last use
      retry: 1,
      refetchOnWindowFocus: true,  // refetch when user returns to the tab/app
    },
  },
})
```

Tune `staleTime` per query if needed — some data changes rarely (user profile), some changes often (notifications).

## Showing the loading state

Use `isPending` not `isFetching` for the loading indicator. `isPending` is true only when there is no cached data at all. `isFetching` is true on every fetch including background refreshes — using it would show a spinner on every refocus, defeating the whole pattern.

```ts
const { data, isPending, isFetching } = useQuery({
  queryKey: ["posts"],
  queryFn: fetchPosts,
})

if (isPending) return <LoadingSpinner />  // first load only

return (
  <>
    {isFetching && <SmallRefreshIndicator />}  {/* optional subtle indicator */}
    <PostList posts={data} />
  </>
)
```

The small refresh indicator on `isFetching` is optional — a subtle spinner in the corner or a progress bar is fine, but the content should already be visible.

## Per-query staleTime

Override globally when a specific query has different freshness requirements:

```ts
// User profile: rarely changes, keep fresh longer
const { data: profile } = useQuery({
  queryKey: ["profile", userId],
  queryFn: () => fetchProfile(userId),
  staleTime: 5 * 60 * 1000,  // 5 minutes
})

// Notifications: changes often, refetch more aggressively
const { data: notifications } = useQuery({
  queryKey: ["notifications"],
  queryFn: fetchNotifications,
  staleTime: 10 * 1000,  // 10 seconds
  refetchInterval: 30 * 1000,  // poll every 30s
})
```

## Clearing cache on logout

Call `queryClient.clear()` when the user logs out. This removes all cached data so the next session (or a different user on the same device) starts fresh.

```ts
// src/lib/auth.ts
import { queryClient } from "@/lib/query-client"

export async function logout() {
  await supabase.auth.signOut()
  queryClient.clear()
  router.push("/login")
}
```

Don't just redirect — clear first, then redirect. Otherwise briefly mounted components in the new page can read stale data from the previous user's session.

## Prefetching for instant navigation

For routes you know the user will visit (e.g. hovering a link), prefetch ahead of time:

```ts
// Prefetch on hover so the page loads instantly on click
function PostLink({ postId }: { postId: string }) {
  const handleMouseEnter = () => {
    queryClient.prefetchQuery({
      queryKey: ["post", postId],
      queryFn: () => fetchPost(postId),
      staleTime: 30 * 1000,
    })
  }

  return <Link href={`/posts/${postId}`} onMouseEnter={handleMouseEnter}>...</Link>
}
```

## Summary

| Situation | What to show |
|-----------|-------------|
| `isPending` (no cache, first load) | Full loading indicator |
| `isFetching && !isPending` (background refresh) | Optional subtle indicator, always show cached content |
| Data loaded, not fetching | Content, nothing else |
| Logout | `queryClient.clear()` before navigating away |
