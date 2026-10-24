# Next.js review checklist (impact-ranked)

## Blockers

1. Authorization only in `proxy.ts`/middleware or only in the UI.
2. Server Action or route handler without input validation and ownership check.
3. Secrets/DB clients importable from client code (missing `server-only`; non-`NEXT_PUBLIC_` env used client-side).
4. User-specific data cached in a shared `'use cache'` scope.
5. `next` below a patched security floor (see versions.md).
6. `dangerouslySetInnerHTML` with unsanitized input.

## Should-fix

1. `"use client"` too high in the tree (whole page client-side for one button).
2. Request waterfalls: sequential awaits that could be `Promise.all` or parallel Suspense boundaries.
3. Missing `loading`/Suspense/error boundaries on slow or failing data.
4. Large client dependencies where a server render suffices; unoptimized images (use `next/image` with sizes).
5. Missing accessible names, focus traps in dialogs, or keyboard support.
6. `useEffect` used for data fetching or derived state.
7. Deprecated runtime or config (`runtime = 'edge'`, `middleware.ts`, `experimental.ppr`).

## Nits

- Naming, file colocation and import order beyond the linter.
- Soft-deprecated patterns in untouched files: mention once.

## Finding format

`app/projects/[id]/page.tsx:12` **[blocker]** `getProject` reads by id without owner filter.
Fix: route through `lib/dal.ts#getProject`, which scopes by `ownerId` and returns a DTO.
