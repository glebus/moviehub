import Combine
import Observation
import DomainModels
import DomainRepositories

@MainActor
@Observable
public final class FavoritesRepository: FavoritesRepositoryProtocol {
    private let storage: SwiftDataStorage
    private let favoritesByListSubject: CurrentValueSubject<[FavoriteListID: [Movie]], Never>
    private let favoriteListByMovieSubject: CurrentValueSubject<[MovieID: FavoriteListID], Never>
    public private(set) var favoritesByList: [FavoriteListID: [Movie]]
    public var favoritesByListSequence: any AsyncSequence<[FavoriteListID: [Movie]], Never> {
        favoritesByListSubject.values
    }
    public private(set) var favoriteListByMovie: [MovieID: FavoriteListID]
    public var favoriteListByMovieSequence: any AsyncSequence<[MovieID: FavoriteListID], Never> {
        favoriteListByMovieSubject.values
    }

    public init(storage: SwiftDataStorage) {
        self.storage = storage
        self.favoritesByList = [:]
        self.favoriteListByMovie = [:]
        self.favoritesByListSubject = CurrentValueSubject([:])
        self.favoriteListByMovieSubject = CurrentValueSubject([:])
    }

    public func fetchFavorites(userId: UserID, listId: FavoriteListID) async throws -> [Movie] {
        let favorites = try await storage.fetchFavorites(userId: userId, listId: listId)
        favoritesByList[listId] = favorites
        favoriteListByMovie = favoriteListByMovie.filter { $0.value != listId }
        for movie in favorites {
            favoriteListByMovie[movie.id] = listId
        }
        favoritesByListSubject.send(favoritesByList)
        favoriteListByMovieSubject.send(favoriteListByMovie)
        return favorites
    }

    public func favoriteListId(userId: UserID, movieId: MovieID) async throws -> FavoriteListID? {
        if let cached = favoriteListByMovie[movieId] {
            return cached
        }
        let listId = try await storage.favoriteListId(userId: userId, movieId: movieId)
        if let listId {
            favoriteListByMovie[movieId] = listId
            favoriteListByMovieSubject.send(favoriteListByMovie)
        }
        return listId
    }

    public func addFavorite(userId: UserID, movie: MovieDetails, listId: FavoriteListID) async throws {
        try await storage.addFavorite(userId: userId, movie: movie, listId: listId)
        if let existingListId = favoriteListByMovie[movie.id], existingListId != listId {
            favoritesByList[existingListId]?.removeAll { $0.id == movie.id }
        }

        var movies = favoritesByList[listId] ?? []
        if !movies.contains(where: { $0.id == movie.id }) {
            movies.append(Movie(id: movie.id, title: movie.title, year: nil, posterURL: movie.posterURL))
        }
        favoritesByList[listId] = movies
        favoriteListByMovie[movie.id] = listId
        favoritesByListSubject.send(favoritesByList)
        favoriteListByMovieSubject.send(favoriteListByMovie)
    }

    public func removeFavorite(userId: UserID, movieId: MovieID) async throws {
        try await storage.removeFavorite(userId: userId, movieId: movieId)
        if let listId = favoriteListByMovie[movieId] {
            favoritesByList[listId]?.removeAll { $0.id == movieId }
        }
        favoriteListByMovie[movieId] = nil
        favoritesByListSubject.send(favoritesByList)
        favoriteListByMovieSubject.send(favoriteListByMovie)
    }

    public func clearCaches() {
        favoritesByList = [:]
        favoriteListByMovie = [:]
        favoritesByListSubject.send([:])
        favoriteListByMovieSubject.send([:])
    }
}
