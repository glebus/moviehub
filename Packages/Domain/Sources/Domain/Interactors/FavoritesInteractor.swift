import Foundation
import Observation
import Utilities

@MainActor
@Observable
public final class FavoritesInteractor: FavoritesInteractorProtocol {
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let sessionInteractor: SessionInteractorProtocol
    public private(set) var favoritesByList: [FavoriteListID: [Movie]]
    public private(set) var favoriteListByMovie: [MovieID: FavoriteListID]
    @ObservationIgnored private var sessionTask: Task<Void, Never>?

    public init(
        favoritesRepository: FavoritesRepositoryProtocol,
        sessionInteractor: SessionInteractorProtocol
    ) {
        self.favoritesRepository = favoritesRepository
        self.sessionInteractor = sessionInteractor
        self.favoritesByList = [:]
        self.favoriteListByMovie = [:]
        observeSession()
    }

    deinit {
        sessionTask?.cancel()
    }

    public func refreshFavorites(listId: FavoriteListID) async throws {
        let user = try requireUser()
        let favorites = try await favoritesRepository.fetchFavorites(userId: user.id, listId: listId)
        favoritesByList[listId] = favorites
        removeMovieMappings(for: listId)
        for movie in favorites {
            favoriteListByMovie[movie.id] = listId
        }
    }

    public func addFavorite(movie: MovieDetails, listId: FavoriteListID) async throws {
        let user = try requireUser()
        try await favoritesRepository.addFavorite(userId: user.id, movie: movie, listId: listId)

        if let existingListId = favoriteListByMovie[movie.id], existingListId != listId {
            favoritesByList[existingListId]?.removeAll { $0.id == movie.id }
        }

        var list = favoritesByList[listId] ?? []
        if !list.contains(where: { $0.id == movie.id }) {
            list.append(Movie(id: movie.id, title: movie.title, year: nil, posterURL: movie.posterURL))
        }
        favoritesByList[listId] = list
        favoriteListByMovie[movie.id] = listId
    }

    public func removeFavorite(movieId: MovieID) async throws {
        let user = try requireUser()
        try await favoritesRepository.removeFavorite(userId: user.id, movieId: movieId)
        if let listId = favoriteListByMovie[movieId] {
            favoritesByList[listId]?.removeAll { $0.id == movieId }
        }
        favoriteListByMovie[movieId] = nil
    }

    public func favoriteListId(movieId: MovieID) async throws -> FavoriteListID? {
        if let listId = favoriteListByMovie[movieId] {
            return listId
        }
        let user = try requireUser()
        let listId = try await favoritesRepository.favoriteListId(userId: user.id, movieId: movieId)
        if let listId {
            favoriteListByMovie[movieId] = listId
        }
        return listId
    }

    private func requireUser() throws -> User {
        guard let user = sessionInteractor.currentUser else {
            throw AuthRequiredError()
        }
        return user
    }

    private func observeSession() {
        sessionTask = observeChanges({ [sessionInteractor] in sessionInteractor.currentUser }) { [weak self] user in
            await self?.handleSessionChange(user)
        }
    }

    func handleSessionChange(_ user: User?) async {
        if user == nil {
            favoritesByList = [:]
            favoriteListByMovie = [:]
        }
    }

    private func removeMovieMappings(for listId: FavoriteListID) {
        favoriteListByMovie = favoriteListByMovie.filter { $0.value != listId }
    }
}
