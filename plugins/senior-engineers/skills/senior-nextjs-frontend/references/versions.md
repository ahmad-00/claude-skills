# Next.js stack versions (last verified: 2026-10-25)

## Core

| Component | Current | Notes |
|---|---|---|
| Next.js | 16.4.1+ (Active LTS); 15.5.28+ (Maintenance LTS) | 16.4 announced 2026-10-06. **16.4.1 / 15.5.28 (2026-10-14) are security releases**: critical unauthenticated RCE in `'use cache'` with typed arguments, critical RCE in image optimization with SVG input on glibc Linux (workaround: sharp ≥ 0.35.5), and a Server Actions DoS |
| React | 19.3 (bundled with Next 16.4) | Stable View Transitions, Fragment Refs |
| Next 17 | not released | Cache Components expected to become the default |
| Node.js | ≥ 20.9 required since Next 16.0 | **verify** whether 16.x raised the floor |
| Vitest | 5.x (4.1.x still gets backports) | Browser Mode stable since 4.0 |
| Playwright | 1.64.x | — |
| Tailwind CSS | v4 (CSS-first `@theme` config) | **verify** current minor |
| React Compiler | stable; Next has `reactCompiler` option | **verify** current version |

## Timeline of relevant changes

- **16.0 (2025-10-21)**:
  - Turbopack is the default bundler.
  - Cache Components arrive behind `cacheComponents`.
  - `experimental.ppr` removed.
  - `middleware.ts` → `proxy.ts` (Node runtime).
  - Async `params`/`searchParams` required.
  - `next lint` removed.
- **16.3 (2026-08)**:
  - Instant Navigations / Partial Prefetching.
  - Auto-managed AGENTS.md block; bundled docs in `next/dist/docs`.
  - `experimental.useCache` deprecated.
  - **Edge Runtime deprecated:** setting `runtime = 'edge'` is no longer supported; routes run on Node.js.
- **16.4 (2026-10-06)**:
  - Cache Components recommended for every app and enabled by default in create-next-app.
  - `ensureStatic` route config.
  - `navigation()` / `prefetch()` from `next/cache`.
  - `next upgrade --agent`, `experimental.agentUpgrade`.

## Security floors

- October 2026 release: `next` ≥ 16.4.1 (or ≥ 15.5.28 on the 15 line). Below that, `'use cache'`, image optimization with SVG, and Server Actions are exploitable.
- React2Shell (CVE-2025-55182): patched floors are 15.0.5, 15.1.9, 15.2.6, 15.3.6, 15.4.8, 15.5.7 and 16.0.7.
- Follow-up RSC advisories require React RSC packages ≥ 19.2.3. Upgrade `next` itself (it vendors the RSC packages).
- CVE-2025-29927 (middleware bypass): never rely on middleware/proxy as the only authorization layer.

## Old patterns / deprecated APIs → replacement

| Old | Replace with |
|---|---|
| `middleware.ts` / `export function middleware` | `proxy.ts` / `export function proxy` (Node runtime) |
| `export const runtime = 'edge'` | remove (Node runtime) |
| `experimental.ppr`, `experimental.useCache`, `experimental.dynamicIO` | `cacheComponents: true` (+ `partialPrefetching`) |
| `unstable_cache`, `fetch(..., { next: { revalidate } })` as primary caching | `'use cache'` + `cacheLife` + `cacheTag` |
| `export const dynamic = 'force-static'` (under Cache Components) | `'use cache'`; `ensureStatic` to enforce |
| Sync `params.id` | `const { id } = await params` |
| `next lint` | `eslint .` / `biome check` |
| `useFormState` | `useActionState` |
| `forwardRef` for passing refs (React 19+) | `ref` as a prop |
| Pages Router `getServerSideProps` in new code | App Router Server Components |
| `tailwind.config.js` theme (v4 projects) | CSS `@theme` |

## Agent-guidance note

Vercel's January 2026 evals found a compressed docs index in AGENTS.md outperformed on-demand skills for API knowledge. This skill therefore focuses on workflows and decisions; let the bundled docs supply API details.
