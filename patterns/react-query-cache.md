# React Query Cache Pattern

The goal is instant-feeling navigation and interaction. Data loads once, gets cached, and subsequent views show immediately. Mutations feel instant too — update the cache first, let the server catch up in the background.

## The rules

1. **Show a loading indicator only on first load** — when there is no cached data yet
2. **On subsequent visits show cached data immediately** — no spinner, no layout shift. Stale data is fine; React Query refetches in the background and updates the UI if the new data differs
3. **Use optimistic updates for mutations** — apply the change to the cache immediately on user action, before the server responds
4. **Clear the cache on logout** — so the next user session starts fresh

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

## Optimistic updates with setQueryData

Reads feel instant because of caching. Mutations can feel instant too — update the cache immediately when the user acts, then let the server confirm in the background. If the server fails, roll back.

```ts
import { useMutation, useQueryClient } from "@tanstack/react-query"

function useLikePost() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (postId: string) => likePost(postId),

    onMutate: async (postId) => {
      // Cancel any in-flight refetches so they don't overwrite the optimistic update
      await queryClient.cancelQueries({ queryKey: ["posts"] })

      // Snapshot the current cache value for rollback
      const previous = queryClient.getQueryData<Post[]>(["posts"])

      // Apply the optimistic update immediately
      queryClient.setQueryData<Post[]>(["posts"], (old) =>
        old?.map((post) =>
          post.id === postId ? { ...post, liked: true, likes: post.likes + 1 } : post
        )
      )

      return { previous }  // returned context is passed to onError
    },

    onError: (_err, _postId, context) => {
      // Roll back to the snapshot on failure
      if (context?.previous) {
        queryClient.setQueryData(["posts"], context.previous)
      }
    },

    onSettled: () => {
      // Refetch to sync with the server regardless of success or failure
      queryClient.invalidateQueries({ queryKey: ["posts"] })
    },
  })
}
```

Usage in a component — no loading state needed for the interaction itself:

```tsx
function PostCard({ post }: { post: Post }) {
  const likePost = useLikePost()

  return (
    <button onClick={() => likePost.mutate(post.id)}>
      {post.liked ? "♥" : "♡"} {post.likes}
    </button>
  )
}
```

The user taps, the count increments instantly, and the server request happens silently. If it fails, the count rolls back.

### setQueryData for simpler cases

When you don't need rollback (e.g. adding a new item to a list and you'll refetch anyway), skip `onMutate` and just update the cache in `onSuccess`:

```ts
useMutation({
  mutationFn: createPost,
  onSuccess: (newPost) => {
    queryClient.setQueryData<Post[]>(["posts"], (old) =>
      old ? [newPost, ...old] : [newPost]
    )
  },
})
```

Use the full `onMutate` / `onError` rollback pattern when the action is visible and reversing it would be jarring (likes, toggles, deletes). Use the simpler `onSuccess` pattern when the mutation creates new data and a brief delay before it appears is acceptable.

## Summary

| Situation | What to show |
|-----------|-------------|
| `isPending` (no cache, first load) | Full loading indicator |
| `isFetching && !isPending` (background refresh) | Optional subtle indicator, always show cached content |
| Data loaded, not fetching | Content, nothing else |
| Logout | `queryClient.clear()` before navigating away |
| Mutation (visible toggle/delete) | `setQueryData` in `onMutate` + rollback in `onError` |
| Mutation (new item creation) | `setQueryData` in `onSuccess`, simpler, no rollback needed |
