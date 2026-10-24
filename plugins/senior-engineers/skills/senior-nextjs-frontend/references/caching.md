# Cache Components cheat sheet (Next 16.x)

## Mental model

- `'use cache'` marks a function or component whose output may be cached. Its arguments and closed-over values are the cache key.
- `cacheLife('seconds' | 'minutes' | 'hours' | 'days' | 'weeks' | 'max' | custom)` sets the lifetime; `cacheTag('x')` enables targeted invalidation.
- Anything request-specific (`cookies()`, `headers()`, session) must sit outside cached scopes and inside `<Suspense>`.
- The build fails when uncached request-time data blocks the static shell. Fix the boundary instead of disabling the check.

## Patterns

```tsx
export default async function Page({ params }: { params: Promise<{ id: string }> }) {
  return (
    <>
      <StaticHeader />
      <Suspense fallback={<Skeleton />}>
        <UserPanel />
      </Suspense>
      <Suspense fallback={<Skeleton />}>
        {params.then(({ id }) => <Product id={id} />)}
      </Suspense>
    </>
  );
}

async function Product({ id }: { id: string }) {
  'use cache';
  cacheLife('hours');
  cacheTag(`product:${id}`);
  return <ProductView data={await getProductPublic(id)} />;
}
```

## 16.4 controls

- `export const ensureStatic = 'navigation' | 'prefetch' | 'shell'` on a page or layout fails the build if dynamic content sneaks in. Use it for marketing, docs and catalog routes.
- `await navigation()` (from `next/cache`) inside a component excludes it from prefetches; content loads on real navigation.
- `await prefetch()` excludes content from the route shell until an explicit prefetch.

## Gotchas

- Never put per-user data in a cached scope without the user ID as an argument.
- Non-serializable arguments (class instances, functions) can't be cache keys. Pass IDs instead.
- After mutations, invalidate by tag; don't rely on time-based expiry for user-visible writes.
