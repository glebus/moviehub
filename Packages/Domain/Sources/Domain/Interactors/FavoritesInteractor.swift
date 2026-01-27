import Foundation

@MainActor
public final class FavoritesInteractor: FavoritesInteractorProtocol {
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let sessionInteractor: SessionInteractor
    private let subject: AsyncStreamSubject<[Movie]>
    private var favoritesCache: [Movie]
    nonisolated(unsafe) private var sessionTask: Task<Void, Never>?

    public init(favoritesRepository: FavoritesRepositoryProtocol, sessionInteractor: SessionInteractor) {
        self.favoritesRepository = favoritesRepository
        self.sessionInteractor = sessionInteractor
        self.favoritesCache = []
        self.subject = AsyncStreamSubject(initial: [])
        observeSession()
    }

    deinit {
        sessionTask?.cancel()
    }

    public func favorites() -> [Movie] {
        favoritesCache
    }

    public var favoritesStream: AsyncStream<[Movie]> {
        subject.stream
    }

    public func refresh() async throws {
        guard let user = sessionInteractor.currentUser() else {
            throw AuthRequiredError()
        }
        let updated = try await favoritesRepository.fetchFavorites(userId: user.id)
        favoritesCache = updated
        await subject.send(updated)
    }

    public func toggle(movie: MovieDetails) async throws -> Bool {
        guard let user = sessionInteractor.currentUser() else {
            throw AuthRequiredError()
        }

        let isFavorite = try await favoritesRepository.existsFavorite(userId: user.id, movieId: movie.id)
        if isFavorite {
            try await favoritesRepository.removeFavorite(userId: user.id, movieId: movie.id)
        } else {
            try await favoritesRepository.addFavorite(userId: user.id, movie: movie)
        }

        try await refresh()
        return !isFavorite
    }

    public func isFavorite(movieId: MovieID) -> Bool {
        favoritesCache.contains { $0.id == movieId }
    }

    private func observeSession() {
        sessionTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await user in sessionInteractor.currentUserStream {
                if user == nil {
                    favoritesCache = []
                    await subject.send([])
                } else {
                    try? await refresh()
                }
            }
        }
    }
}
