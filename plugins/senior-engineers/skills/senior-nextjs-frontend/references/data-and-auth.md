# Data access layer and auth

## DAL shape

```ts
// lib/dal.ts
import 'server-only';
import { cache } from 'react';
import { redirect } from 'next/navigation';
import { getSession } from '@/lib/session'; // project's auth library

export const verifySession = cache(async () => {
  const session = await getSession();
  if (!session?.userId) redirect('/login');
  return { userId: session.userId, role: session.role };
});

export async function getProject(projectId: string) {
  const { userId } = await verifySession();
  const project = await db.project.findFirst({ where: { id: projectId, ownerId: userId } });
  if (!project) return null;                      // don't leak existence
  return { id: project.id, name: project.name };  // DTO, not the row
}
```

Session reads are request-time data, so never call them inside a `'use cache'` scope. Pass the userId in as an argument instead (it becomes part of the cache key).

## Server Action template

```ts
'use server';
import { z } from 'zod';
import { updateTag } from 'next/cache';
import { verifySession } from '@/lib/dal';

const Input = z.object({ projectId: z.string().uuid(), name: z.string().min(1).max(120) });

export async function renameProject(_prev: unknown, formData: FormData) {
  const { userId } = await verifySession();
  const parsed = Input.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return { ok: false, errors: parsed.error.flatten().fieldErrors };
  const updated = await db.project.updateMany({
    where: { id: parsed.data.projectId, ownerId: userId }, data: { name: parsed.data.name },
  });
  if (updated.count === 0) return { ok: false, errors: { form: ['Not found'] } };
  updateTag(`project:${parsed.data.projectId}`);
  return { ok: true };
}
```

Use the project's validation library and the revalidation API available in its Next version; `revalidateTag` works on older versions.

## Rules

- Cookies: `httpOnly`, `secure`, `sameSite=lax`; rotate the session on login; destroy it server-side on logout.
- `proxy.ts` may redirect unauthenticated users for UX; the DAL still enforces.
- Route handlers that accept cross-origin requests need explicit CORS and CSRF reasoning; configure `serverActions.allowedOrigins` behind proxies.
- Environment: only `NEXT_PUBLIC_*` reaches the client; validate env at startup (schema) so missing secrets fail the build, not a request.
