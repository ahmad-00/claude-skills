# Swift concurrency in app code

## Defaults for app targets (Xcode 26+)

- With `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, unannotated types and functions are MainActor-isolated. That's right for views and view models.
- With `NonisolatedNonsendingByDefault` (approachable concurrency), `nonisolated async` functions run on the caller's actor. Mark CPU-heavy functions `@concurrent` to move them off it.

## Codable DTO pitfall

Under MainActor-by-default, a plain `struct UserDTO: Codable` becomes MainActor-isolated, and decoding it in a background context produces isolation errors. Declare DTOs explicitly:

```swift
nonisolated struct UserDTO: Codable, Sendable {
    let id: UUID
    let name: String
}
```

## Patterns

```swift
@Observable
final class ItemsModel {                  // MainActor by default in app targets
    private(set) var items: [Item] = []
    private(set) var error: Error?
    private let api: APIClient

    init(api: APIClient) { self.api = api }

    func load() async {
        do { items = try await api.fetchItems().map(Item.init) }
        catch is CancellationError { }
        catch { self.error = error }
    }
}

struct APIClient: Sendable {
    let session: URLSession
    let baseURL: URL

    @concurrent
    func fetchItems() async throws -> [ItemDTO] {
        let (data, response) = try await session.data(from: baseURL.appending(path: "items"))
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode([ItemDTO].self, from: data)
    }
}
```

View: `.task { await model.load() }`, or `.task(id: filter)` to reload and cancel on change.

## Rules

- Prefer value types and actors over locks. If you need a lock, use `Mutex` (Synchronization) and keep it private.
- `@unchecked Sendable` and `nonisolated(unsafe)` need a comment proving safety; reviewers treat them as blockers otherwise.
- Don't capture non-Sendable state in `Task { }` closures crossing isolation; pass values.
- Unstructured `Task {}` in views is usually wrong; use `.task`.
- Long-running loops check `Task.isCancelled` / `try Task.checkCancellation()`.
