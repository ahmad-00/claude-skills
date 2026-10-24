# Android review checklist (impact-ranked)

## Blockers

1. Main-thread disk/network I/O; `runBlocking` in UI paths.
2. Leaks: Activity/Context/View held in ViewModel, singletons or static fields.
3. Secrets in source, BuildConfig or plain prefs; tokens logged.
4. Exported components without protection; mutable PendingIntents.
5. Room migration that can lose data; destructive fallback in production.
6. targetSdk below the current Play requirement in a release branch.

## Should-fix

1. State collected without lifecycle awareness (`collectAsState` in Android UI).
2. ViewModel exposing `MutableStateFlow` or mutable collections.
3. Hard-coded dispatchers (inject them for testability).
4. Missing keys in lazy lists; unstable parameters causing recomposition in hot paths.
5. Missing insets handling (content under system bars) or broken predictive back.
6. Accessibility: missing contentDescription, small touch targets, text not in sp.
7. kapt where KSP is available; Kotlin Android plugin applied on AGP 9.
8. Missing tests for ViewModel logic.

## Nits

- Naming, detekt/ktlint style not enforced by CI.
- Soft-deprecated APIs in untouched code: mention once.

## Finding format

`feature/list/ListViewModel.kt:22` **[should-fix]** Exposes `MutableStateFlow` publicly.
Fix: `private val _state = MutableStateFlow(UiState()); val state: StateFlow<UiState> = _state.asStateFlow()`.
