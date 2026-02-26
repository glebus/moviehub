import Combine
import Observation
import DomainModels
import DomainRepositories

@MainActor
@Observable
public final class FavoritesRepository: FavoritesRepositoryProtocol {
    private let storage: SwiftDataStorage
    private let favoritesByListSubject: CurrentValueSubject<[FavoriteListID: [Movie]], Never>
    private let favoriteListsByMovieSubject: CurrentValueSubject<[MovieID: Set<FavoriteListID>], Never>
    public private(set) var favoritesByList: [FavoriteListID: [Movie]]
    public var favoritesByListSequence: any AsyncSequence<[FavoriteListID: [Movie]], Never> {
        favoritesByListSubject.values
    }
    public private(set) var favoriteListsByMovie: [MovieID: Set<FavoriteListID>]
    public var favoriteListsByMovieSequence: any AsyncSequence<[MovieID: Set<FavoriteListID>], Never> {
        favoriteListsByMovieSubject.values
    }

    public init(storage: SwiftDataStorage) {
        self.storage = storage
        self.favoritesByList = [:]
        self.favoriteListsByMovie = [:]
        self.favoritesByListSubject = CurrentValueSubject([:])
        self.favoriteListsByMovieSubject = CurrentValueSubject([:])
    }

    public func fetchFavorites(userId: UserID, listId: FavoriteListID) async throws -> [Movie] {
        let favorites = try await storage.fetchFavorites(userId: userId, listId: listId)
        favoritesByList[listId] = favorites
        removeMembership(for: listId)
        for movie in favorites {
            favoriteListsByMovie[movie.id, default: []].insert(listId)
        }
        favoritesByListSubject.send(favoritesByList)
        favoriteListsByMovieSubject.send(favoriteListsByMovie)
        return favorites
    }

    public func favoriteListIds(userId: UserID, movieId: MovieID) async throws -> Set<FavoriteListID> {
        if let cached = favoriteListsByMovie[movieId] {
            return cached
        }
        let listIds = try await storage.favoriteListIds(userId: userId, movieId: movieId)
        if !listIds.isEmpty {
            favoriteListsByMovie[movieId] = listIds
            favoriteListsByMovieSubject.send(favoriteListsByMovie)
        }
        return listIds
    }

    public func addFavorite(userId: UserID, movie: MovieDetails, listId: FavoriteListID) async throws {
        try await storage.addFavorite(userId: userId, movie: movie, listId: listId)
        var movies = favoritesByList[listId] ?? []
        if !movies.contains(where: { $0.id == movie.id }) {
            movies.append(Movie(id: movie.id, title: movie.title, year: nil, posterURL: movie.posterURL))
        }
        favoritesByList[listId] = movies
        favoriteListsByMovie[movie.id, default: []].insert(listId)
        favoritesByListSubject.send(favoritesByList)
        favoriteListsByMovieSubject.send(favoriteListsByMovie)
    }

    public func removeFavorite(userId: UserID, movieId: MovieID, listId: FavoriteListID) async throws {
        try await storage.removeFavorite(userId: userId, movieId: movieId, listId: listId)
        favoritesByList[listId]?.removeAll { $0.id == movieId }
        if var memberships = favoriteListsByMovie[movieId] {
            memberships.remove(listId)
            favoriteListsByMovie[movieId] = memberships.isEmpty ? nil : memberships
        }
        favoritesByListSubject.send(favoritesByList)
        favoriteListsByMovieSubject.send(favoriteListsByMovie)
    }

    public func removeFavorite(userId: UserID, movieId: MovieID) async throws {
        try await storage.removeFavorite(userId: userId, movieId: movieId)
        for listId in favoriteListsByMovie[movieId] ?? [] {
            favoritesByList[listId]?.removeAll { $0.id == movieId }
        }
        favoriteListsByMovie[movieId] = nil
        favoritesByListSubject.send(favoritesByList)
        favoriteListsByMovieSubject.send(favoriteListsByMovie)
    }

    public func clearCaches() {
        favoritesByList = [:]
        favoriteListsByMovie = [:]
        favoritesByListSubject.send([:])
        favoriteListsByMovieSubject.send([:])
    }

    private func removeMembership(for listId: FavoriteListID) {
        for movieId in Array(favoriteListsByMovie.keys) {
            guard var memberships = favoriteListsByMovie[movieId] else { continue }
            memberships.remove(listId)
            favoriteListsByMovie[movieId] = memberships.isEmpty ? nil : memberships
        }
    }
}
