# iOS review checklist (impact-ranked)

## Blockers

1. Data races: `@unchecked Sendable`/`nonisolated(unsafe)` without proof; shared mutable state across tasks.
2. UI mutations off the MainActor.
3. Secrets in UserDefaults/plists/source; tokens in logs.
4. Force unwraps / `try!` on network, file or user data.
5. Missing UIScene adoption when building with the iOS 27 SDK; missing launch screen; privacy manifest gaps.
6. Retain cycles in long-lived closures (`self` captured strongly in stored closures/timers).

## Should-fix

1. Unstable `ForEach` identity (indices, `id: \.self` on non-unique values).
2. Large `body` recomputation: whole model passed where one value suffices; heavy work in `body`.
3. Unstructured `Task {}` in views instead of `.task`; missing cancellation.
4. Missing loading/empty/error states; errors swallowed.
5. Accessibility: missing labels, fixed font sizes, tap targets < 44pt.
6. Hard-coded strings not in the String Catalog.
7. Missing tests for model logic.

## Nits

- Soft-deprecated modifiers in untouched code (mention once).
- Naming and file organization.

## Finding format

`Features/Items/ItemsView.swift:31` **[should-fix]** `ForEach(model.items.indices, id: \.self)` breaks identity on insert.
Fix: make `Item: Identifiable` and use `ForEach(model.items) { item in ... }`.
