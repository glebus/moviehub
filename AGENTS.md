# AGENTS.md — MovieHub

These instructions describe how an LLM should work in this repository. Follow them exactly.

## Architecture Rules (Must Follow)
- Layers: **Domain**, **Data**, **Features**, **App**.
- App composes concrete implementations and passes dependencies downward.
- **Never import `Data` from `Features`.**
- **Features must import only `DomainModels` and `DomainUseCases` from the Domain package** (plus feature-local modules like `Router` / `AuthButton`).
- `DomainMocks` is allowed in feature targets only for previews/test helpers (e.g. `preview()` builders). Do not use it as a runtime dependency contract.
- **Features must not import `DomainRepositories`.**
- `Data` may import `DomainModels` + `DomainRepositories` only.
- `DomainUseCases` depends on `DomainModels` + `DomainRepositories`.
- `DomainRepositories` depends on `DomainModels`.
- `DomainModels` has no local package dependencies.

## Domain Package Structure (Current)
The SwiftPM package is named `Domain`, but it exports multiple products:
- There is **no** `Domain` module/product anymore.
- `DomainModels` — models, domain errors, pure domain utilities (e.g. `UsernameNormalizer`)
- `DomainUseCases` — single-purpose use cases + feature-facing closure typealiases
- `DomainRepositories` — repository protocols only
- `DomainMocks` — mocks for previews/tests (repositories + use-case-style mocks)

### Import Matrix (Strict)
- `Features`: `import DomainModels`, `import DomainUseCases`
- `Data`: `import DomainModels`, `import DomainRepositories`
- `App`: `import DomainModels`, `import DomainUseCases`, `import Data`, feature modules
- `DomainUseCases`: `import DomainModels`, `import DomainRepositories`
- `DomainMocks`: may import all Domain products as needed

## Layer Responsibilities
**DomainModels**
- Pure domain types and value semantics.
- IDs, entities, domain errors.
- Pure domain helpers with no I/O or app state (e.g. username normalization).

**DomainRepositories**
- Repository protocols (contracts only).
- Repository protocols may expose repository-owned state and async sequences.
- No UI concerns, no concrete storage/network code.
- Repository protocols must expose **Swift Concurrency types** (`async/await`, `AsyncSequence`) and must not leak `Combine` types.

**DomainUseCases**
- Business operations only.
- Single responsibility per use case type/file.
- Feature-facing closure aliases (`typealias`) live here.
- No `@Observable` use cases.
- No use case protocols.
- No mutable app state in use cases (repositories own state/caches).
- Use cases may store collaborator references (repository protocol dependencies).

**Data**
- Implements repository protocols from `DomainRepositories`.
- Network (TMDb), persistence (SwiftData), DTO mapping.
- May own local persisted/in-memory state required by repository contracts.
- No business rules (business orchestration belongs in use cases).

**Features**
- UI modules + ViewModels (view state only).
- Builders are feature entry points.
- ViewModels depend on closures/typealiases from `DomainUseCases`, not repository protocols.
- ViewModels consume repository-backed async sequences through injected closure sources.
- Cross-feature/app navigation is emitted through Router.
- Feature-local multi-step navigation may be mediated by a feature coordinator object inside the feature.

**App**
- Composition root (DI).
- Creates concrete repositories and use cases.
- Wires closures into feature builders/view models.
- Decides when to pass direct repository state closures vs use-case action closures.

## Use Case Rules (Strict)
- One use case = one responsibility.
- Each concrete use case must live in its own file.
- Do not create grouped/facade use cases (e.g. `SessionUseCase` holding login/logout/currentUser).
- Do not create `*UseCaseProtocol` files.
- Expose feature dependencies as closures (prefer shared closure `typealias`es in `DomainUseCases/UseCaseClosureTypes.swift`).
- Treat closure `typealias`es as the public feature-facing use-case API surface (instead of `*UseCaseProtocol` abstractions).
- Use cases should be plain types (`struct`/`final class`) without observation.
- Use cases must not own domain state caches; repositories own state.

### What Stays as a Use Case vs Direct Repository Closure
Use a **UseCase** when logic includes any of:
- auth checks
- orchestration across repositories
- validation / normalization rules
- mutation commands
- error translation/domain-specific branching

Use a **direct repository closure from App composition** for simple reads/streams that are pure state passthroughs, for example:
- current user reader/sequence
- favorite lists reader/sequence
- favorites caches reader/sequence

## Repository State & Observation (Current Pattern)
Repositories own local state that was previously in interactors, including:
- `ProfileRepositoryProtocol`: `currentUser`, `currentUserSequence`
- `FavoriteListsRepositoryProtocol`: `lists`, `listsSequence`
- `FavoritesRepositoryProtocol`: `favoritesByList`, `favoritesByListSequence`, `favoriteListsByMovie`, `favoriteListsByMovieSequence`

### Feature Observation Pattern (Strict)
- `Utilities` package was removed.
- Do not use `observeChanges`.
- Do not use manual `withObservationTracking` loops for runtime subscriptions.
- ViewModels observe state changes via injected async sequence closures and `Task { for await ... }` loops.
- Cancel sequence tasks in `deinit` (or lifecycle teardown) to avoid leaks.

### Combine vs Swift Concurrency Boundary (Important)
- **Domain surface must stay pure Swift Concurrency**:
  - repository protocols expose `AsyncSequence`
  - use-case APIs are `async` closures / async methods
  - Features consume `AsyncSequence` only
- **Data layer may use Combine internally** as an implementation detail (e.g. `CurrentValueSubject`) to manage mutable state streams.
- Data repositories should bridge Combine -> Concurrency by exposing `subject.values` as `AsyncSequence` for Domain protocol conformance.
- Never expose `AnyPublisher`, `Publisher`, or Combine-specific types in `DomainModels`, `DomainUseCases`, `DomainRepositories`, or Features.

## Builders and ViewModels
- Each feature exposes a `Builder` struct as the entry point.
- Builder receives dependencies in `init` and returns a screen via `build()`.
- Screens receive a ViewModel in the initializer.
- ViewModels are `@MainActor` and `@Observable` (view state only).
- Use cases are not `@Observable`.
- Builders/ViewModels in Features must not depend on `Data` or `DomainRepositories`.
- `AuthButtonBuilder` is stored in ViewModels (not screens).
- ViewModels expose sync methods for SwiftUI (`tap` handlers) that wrap internal async methods.
- Async methods should remain `internal` for `@testable import` tests.
- If a feature owns a multi-step flow, prefer a feature coordinator object for in-feature navigation.
- In that pattern, ViewModels should depend on the feature coordinator (not directly on `PresentedSheetRouter`) for in-module navigation.

## Naming Conventions
- Protocols must end with `Protocol`.
- Concrete implementations use the base name without `Protocol`.
- Repository protocols live only in `DomainRepositories`.
- Use case names are verb-oriented and specific, e.g.:
- `LoginUseCase`
- `RefreshFavoriteListsUseCase`
- `LookupFavoriteListUseCase`
- `LookupFavoriteListsUseCase`
- `RemoveFavoriteFromListUseCase`
- Closure aliases are action/query oriented, e.g.:
- `LoginAction`
- `CurrentUserReader`
- `FavoriteListsSequenceSource`
- `SearchMoviesAction`
- `LookupFavoriteListsAction`
- `RemoveFavoriteFromListAction`
- Prefer suffixes that reveal behavior:
  - `Reader` for sync reads
  - `Action` for async commands/queries with behavior
  - `SequenceSource` for async streams

## Navigation
- Router owns navigation state.
- Pushes: `router.push(AppPushDestination)`.
- Sheets: `router.present(AppSheetDestination)`.
- App renders destinations from Router state.
- Each tab owns its own `NavigationStack` path.
- Presented sheets should use `PresentedSheetHost` as the single sheet `NavigationStack`.
- `PresentedSheetRouter` owns the sheet-local shared `NavigationPath`.
- Sheet features may append feature-local destination values to `PresentedSheetRouter.path` and register feature-level `.navigationDestination(for:)` handlers in their coordinator view.
- Do not create a second `NavigationStack` inside a sheet feature coordinator when the feature is hosted by `PresentedSheetHost`.
- For sheet multi-step flows (e.g. `FavoriteListCreate`), prefer this split:
  - feature coordinator owns in-feature navigation + external routing through `PresentedSheetRouter`
  - feature ViewModel depends only on the feature coordinator for navigation (not directly on `PresentedSheetRouter`)

## Testing
- Use **Swift Testing**.
- Prefer direct async method calls in tests via `@testable import`.
- No polling/timeouts for ViewModel tests.
- Do not reintroduce observation-tracking helpers in tests.
- Use mocks from `DomainMocks` in Feature tests.
- `DomainMocks` may use Combine internally to back async sequences (existing pattern). Do not introduce Combine into Features or use cases.

### Fast Validation Commands
- `cd Packages/Domain && swift test`
- `cd ../Data && swift test`
- `cd ../Features && swift test`
- `cd ../.. && xcodebuild -scheme moviehub -configuration Debug -destination 'generic/platform=iOS' build`

## Cross‑Platform Guidance
- Keep `DomainModels`, `DomainRepositories`, and `DomainUseCases` cross-platform.
- `Data` and `Features` may be platform-specific if needed, but avoid unnecessary coupling.

## API and Secrets
- Movie API: **TMDb v3**.
- Bearer token is read from `Secrets.xcconfig` via Info.plist key `TMDB_READ_TOKEN`.
- Never commit real tokens. `Secrets.xcconfig` is ignored by git.

## Practical Workflow (LLM-Focused)
- Prefer `swift build` / `swift test` over Xcode for iteration speed.
- Keep changes minimal and aligned with the import matrix above.
- Before adding a new dependency to a Feature ViewModel, ask:
  - Can this be a closure from `DomainUseCases`?
  - Is this a simple state read that should come from a repository closure at App composition?
- If a feature needs a new business action, add a new single-purpose use case file in `DomainUseCases`.
- If a feature needs a new state stream/cache contract, extend the appropriate repository protocol in `DomainRepositories`, implement it in `Data`, then inject closures from App.
