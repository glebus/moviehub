# AGENTS.md — MovieHub

These instructions describe how an LLM should work in this repository. Follow them exactly.

## Architecture rules (must follow)
- Layers: **Domain**, **Data**, **Features**, **App**.
- Dependency graph:
  - Domain has **no dependencies**.
  - Data depends **only on Domain**.
  - Features depends **only on Domain** (and Router/AuthButton inside Features).
  - App depends on all layers and composes them.
- **Never import Data from Features**.

## Layer responsibilities
**Domain**
- Business logic + data state (e.g., current user, favorites state).
- Models, errors, utilities.
- Protocols for repositories + interactors.
- Interactors own data state; ViewModels subscribe via `observeChanges` from `Utilities`.
- Interactors are split by responsibility:
  - `FavoriteListsInteractor` — list CRUD (create, rename, delete, refresh).
  - `FavoritesInteractor` — movie-in-list operations (add/remove favorite, lookup, caches).
  - `SessionInteractor` — user session (login/logout).
- `DomainMocks` product contains mocks for previews/tests (repository mocks + `FavoriteListsInteractorMock`).

**Data**
- Implements Domain protocols.
- Network (TMDb) + persistence (SwiftData) + DTO mapping.
- No business logic; just executes commands from Domain.

**Features**
- UI modules and ViewModels (view state only: loading, error, selection).
- Entry point is a **Builder** struct: receives dependencies in `init`, returns view via `build()`.
- Builders can be injected into other features (composition).
- Navigation uses Router (Feature library); features only emit navigation intents.

**App**
- Composition root (DI).
- Creates concrete implementations and wires features.
- Presents screens based on Router state.

## Naming conventions
- Protocols must end with `Protocol` (e.g., `MovieRepositoryProtocol`, `SessionInteractorProtocol`, `FavoriteListsInteractorProtocol`, `AppRouterProtocol`).
- Concrete implementations use the base name without `Protocol`.
- When a feature needs both list management and movie-favorite operations, inject both `FavoriteListsInteractorProtocol` and `FavoritesInteractorProtocol`. When it only needs one concern, inject only that one.

## Navigation
- Router owns navigation state:
  - Pushes: `router.push(AppPushDestination)`.
  - Sheets: `router.present(AppSheetDestination)`.
- App renders destinations from Router state.
- Each tab has its own `NavigationStack` path.

## Utilities package
- Cross-platform helpers shared by Domain and Features.
- `observeChanges(_:onChange:)` — loop-based observation helper that subscribes to an `@Observable` property via a read closure and delivers changes. Use this instead of manual `withObservationTracking` loops.
- Usage: `observeChanges({ interactor.currentUser }) { [weak self] user in self?.currentUser = user }`
- Sync and async `onChange` overloads are available.

## Builders and ViewModels
- Screens accept a `ViewModel` in the initializer (generated init).
- ViewModels are `@Observable` and `@MainActor`.
- ViewModels should not be `public init` unless needed outside the builder.
- `AuthButtonBuilder` is stored inside ViewModels (not screens).
- ViewModels expose sync methods for SwiftUI (e.g., `loginTapped()`) that wrap internal async methods (e.g., `func login() async`). The async methods have `internal` access so tests can call them directly via `@testable import`.

## Testing
- Use **Swift Testing**.
- Tests call internal async methods directly via `@testable import` — no observation tracking, polling, or timeouts in tests.
- Pattern: `await viewModel.login()` then `#expect(viewModel.state == .success)`.
- Do **not** use `withObservationTracking` or `waitForChange` helpers in tests.
- For computed-state ViewModels (e.g., `FavoriteListViewModel`), set properties directly and assert the computed state.
- Use mocks from `DomainMocks` in Feature tests.
- Prefer `swift test` for fast validation:
  - `cd Packages/Domain && swift test`
  - `cd ../Data && swift test`
  - `cd ../Features && swift test`

## Cross‑platform guidance
- Keep **Domain** cross‑platform.
- **Data** and **Features** may become iOS‑specific, but try to keep them cross‑platform when possible.

## API and secrets
- Movie API: **TMDb v3**.
- Bearer token is read from `Secrets.xcconfig` via Info.plist key `TMDB_READ_TOKEN`.
- Never commit real tokens. `Secrets.xcconfig` is ignored by git.

## Practical workflow
- Prefer `swift build` / `swift test` over Xcode when possible.
- Keep changes minimal and aligned with layer responsibilities.
- Avoid Combine.
- Do not introduce new dependencies without asking.
