import Observation
import DomainModels
import DomainRepositories

@MainActor
@Observable
public final class FavoritesRepository: FavoritesRepositoryProtocol {
    private let storage: SwiftDataStorage
    private let favoritesByListState = ObservableValue<[FavoriteListID: [Movie]]>([:])
    private let favoriteListsByMovieState = ObservableValue<[MovieID: Set<FavoriteListID>]>([:])
    public var favoritesByListSequence: any AsyncSequence<[FavoriteListID: [Movie]], Never> {
        favoritesByListState.updates
    }
    public var favoriteListsByMovieSequence: any AsyncSequence<[MovieID: Set<FavoriteListID>], Never> {
        favoriteListsByMovieState.updates
    }
    public var favoritesByList: [FavoriteListID: [Movie]] { favoritesByListState.value }
    public var favoriteListsByMovie: [MovieID: Set<FavoriteListID>] { favoriteListsByMovieState.value }

    public init(storage: SwiftDataStorage) {
        self.storage = storage
    }

    public func fetchFavorites(userId: UserID, listId: FavoriteListID) async throws -> [Movie] {
        let favorites = try await storage.fetchFavorites(userId: userId, listId: listId)
        var updatedFavoritesByList = favoritesByList
        var updatedFavoriteListsByMovie = favoriteListsByMovie

        updatedFavoritesByList[listId] = favorites
        removeMembership(for: listId, in: &updatedFavoriteListsByMovie)
        for movie in favorites {
            updatedFavoriteListsByMovie[movie.id, default: []].insert(listId)
        }
        applyState(
            favoritesByList: updatedFavoritesByList,
            favoriteListsByMovie: updatedFavoriteListsByMovie
        )
        return favorites
    }

    public func favoriteListIds(userId: UserID, movieId: MovieID) async throws -> Set<FavoriteListID> {
        if let cached = favoriteListsByMovie[movieId] {
            return cached
        }
        let listIds = try await storage.favoriteListIds(userId: userId, movieId: movieId)
        if !listIds.isEmpty {
            var updatedFavoriteListsByMovie = favoriteListsByMovie
            updatedFavoriteListsByMovie[movieId] = listIds
            favoriteListsByMovieState.send(updatedFavoriteListsByMovie)
        }
        return listIds
    }

    public func addFavorite(userId: UserID, movie: MovieDetails, listId: FavoriteListID) async throws {
        try await storage.addFavorite(userId: userId, movie: movie, listId: listId)
        var updatedFavoritesByList = favoritesByList
        var updatedFavoriteListsByMovie = favoriteListsByMovie
        var movies = updatedFavoritesByList[listId] ?? []
        if !movies.contains(where: { $0.id == movie.id }) {
            movies.append(Movie(id: movie.id, title: movie.title, year: nil, posterURL: movie.posterURL))
        }
        updatedFavoritesByList[listId] = movies
        updatedFavoriteListsByMovie[movie.id, default: []].insert(listId)
        applyState(
            favoritesByList: updatedFavoritesByList,
            favoriteListsByMovie: updatedFavoriteListsByMovie
        )
    }

    public func removeFavorite(userId: UserID, movieId: MovieID, listId: FavoriteListID) async throws {
        try await storage.removeFavorite(userId: userId, movieId: movieId, listId: listId)
        var updatedFavoritesByList = favoritesByList
        var updatedFavoriteListsByMovie = favoriteListsByMovie

        updatedFavoritesByList[listId]?.removeAll { $0.id == movieId }
        if var memberships = updatedFavoriteListsByMovie[movieId] {
            memberships.remove(listId)
            updatedFavoriteListsByMovie[movieId] = memberships.isEmpty ? nil : memberships
        }
        applyState(
            favoritesByList: updatedFavoritesByList,
            favoriteListsByMovie: updatedFavoriteListsByMovie
        )
    }

    public func removeFavorite(userId: UserID, movieId: MovieID) async throws {
        try await storage.removeFavorite(userId: userId, movieId: movieId)
        var updatedFavoritesByList = favoritesByList
        var updatedFavoriteListsByMovie = favoriteListsByMovie

        for listId in updatedFavoriteListsByMovie[movieId] ?? [] {
            updatedFavoritesByList[listId]?.removeAll { $0.id == movieId }
        }
        updatedFavoriteListsByMovie[movieId] = nil
        applyState(
            favoritesByList: updatedFavoritesByList,
            favoriteListsByMovie: updatedFavoriteListsByMovie
        )
    }

    public func clearCaches() {
        applyState(favoritesByList: [:], favoriteListsByMovie: [:])
    }

    private func removeMembership(
        for listId: FavoriteListID,
        in favoriteListsByMovie: inout [MovieID: Set<FavoriteListID>]
    ) {
        for movieId in Array(favoriteListsByMovie.keys) {
            guard var memberships = favoriteListsByMovie[movieId] else { continue }
            memberships.remove(listId)
            favoriteListsByMovie[movieId] = memberships.isEmpty ? nil : memberships
        }
    }

    private func applyState(
        favoritesByList: [FavoriteListID: [Movie]],
        favoriteListsByMovie: [MovieID: Set<FavoriteListID>]
    ) {
        favoritesByListState.send(favoritesByList)
        favoriteListsByMovieState.send(favoriteListsByMovie)
    }
}
