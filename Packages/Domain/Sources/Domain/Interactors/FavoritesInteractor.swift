import Foundation
import Observation
import Utilities

@MainActor
@Observable
public final class FavoritesInteractor: FavoritesInteractorProtocol {
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let sessionInteractor: SessionInteractor
    public private(set) var favorites: [Movie]
    @ObservationIgnored private var sessionTask: Task<Void, Never>?

    public init(favoritesRepository: FavoritesRepositoryProtocol, sessionInteractor: SessionInteractor) {
        self.favoritesRepository = favoritesRepository
        self.sessionInteractor = sessionInteractor
        self.favorites = []
        observeSession()
    }

    deinit {
        sessionTask?.cancel()
    }

    public func refresh() async throws {
        guard let user = sessionInteractor.currentUser else {
            throw AuthRequiredError()
        }
        let updated = try await favoritesRepository.fetchFavorites(userId: user.id)
        favorites = updated
    }

    public func toggle(movie: MovieDetails) async throws -> Bool {
        guard let user = sessionInteractor.currentUser else {
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
        favorites.contains { $0.id == movieId }
    }

    private func observeSession() {
        sessionTask = observeChanges({ [sessionInteractor] in sessionInteractor.currentUser }) { [weak self] user in
            await self?.handleSessionChange(user)
        }
    }

    func handleSessionChange(_ user: User?) async {
        if user == nil {
            favorites = []
        } else {
            try? await refresh()
        }
    }
}

