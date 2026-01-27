# MovieHub

MovieHub is a sample SwiftUI app that демонstrates a modular, testable architecture using SwiftPM packages, Swift Concurrency, and TMDb API v3.

## Features
- Search movies (TMDb)
- Movie details (poster, overview, genres)
- Favorites per user
- Lightweight auth (username only)
- Centralized navigation via Router
- Modular SwiftPM packages

## Architecture
Packages live under `Packages/`:

- `Domain`
  - Models, errors, utilities
  - Protocols (repositories + interactors)
  - Interactors (data state + `AsyncStream`)
  - `DomainMocks` product for previews/tests

- `Data`
  - TMDb network implementation (`MovieRepository`)
  - SwiftData storage for users/favorites
  - DTOs + mapping

- `Features`
  - UI modules: `MovieList`, `MovieDetails`, `FavoriteList`, `Profile`, `Auth`, `AuthButton`, `Router`
  - ViewModels hold view state only
  - Navigation intent emitted through `AppRouter`

App target composes everything in `AppContainer` and `RootTabView`.

## Navigation
- Router owns per-tab navigation stacks + sheet presentation.
- Features call `router.push(...)` for pushes and `router.present(...)` for sheets.

## TMDb API Setup
This project uses The Movie Database (TMDb) API v3. The token must not be committed.

1) Create a TMDb account
2) Generate an **API Read Access Token**
3) Copy the example config:

```bash
cp Secrets.example.xcconfig Secrets.xcconfig
```

4) Put your token into `Secrets.xcconfig`:

```
TMDB_READ_TOKEN = YOUR_TMDB_READ_ACCESS_TOKEN_HERE
```

5) Build & run

`Secrets.xcconfig` is ignored by git.

## Testing
Run tests from the package folders:

```bash
cd Packages/Domain && swift test
cd ../Data && swift test
```

## Notes
- Minimum platforms: iOS 17, macOS 15
- No Combine
- Data state lives in Domain Interactors
- View state lives in ViewModels
