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
- Interactors own data state and expose `AsyncStream`.
- `DomainMocks` product contains mocks for previews/tests.

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
- Protocols must end with `Protocol` (e.g., `MovieRepositoryProtocol`, `SessionInteractorProtocol`, `AppRouterProtocol`).
- Concrete implementations use the base name without `Protocol`.

## Navigation
- Router owns navigation state:
  - Pushes: `router.push(AppPushDestination)`.
  - Sheets: `router.present(AppSheetDestination)`.
- App renders destinations from Router state.
- Each tab has its own `NavigationStack` path.

## Builders and ViewModels
- Screens accept a `ViewModel` in the initializer (generated init).
- ViewModels are `@Observable` and `@MainActor`.
- ViewModels should not be `public init` unless needed outside the builder.
- `AuthButtonBuilder` is stored inside ViewModels (not screens).

## Testing
- Use **Swift Testing**.
- Tests should rely on `withObservationTracking` to observe state changes.
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
