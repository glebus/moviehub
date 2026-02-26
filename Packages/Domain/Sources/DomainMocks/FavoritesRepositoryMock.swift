import Combine
import Observation
import DomainModels
import DomainUseCases
import DomainRepositories

@MainActor
@Observable
public final class FavoritesRepositoryMock: FavoritesRepositoryProtocol {
    private var storedFavorites: [UserID: [FavoriteListID: [Movie]]] = [:]
    private var storedFavoriteListsByMovie: [UserID: [MovieID: Set<FavoriteListID>]] = [:]
    public private(set) var favoritesByList: [FavoriteListID: [Movie]] = [:]
    private let favoritesByListSubject = CurrentValueSubject<[FavoriteListID: [Movie]], Never>([:])
    public var favoritesByListSequence: any AsyncSequence<[FavoriteListID: [Movie]], Never> {
        favoritesByListSubject.values
    }
    public private(set) var favoriteListsByMovie: [MovieID: Set<FavoriteListID>] = [:]
    private let favoriteListsByMovieSubject = CurrentValueSubject<[MovieID: Set<FavoriteListID>], Never>([:])
    public var favoriteListsByMovieSequence: any AsyncSequence<[MovieID: Set<FavoriteListID>], Never> {
        favoriteListsByMovieSubject.values
    }

    public init() {}

    public func fetchFavorites(userId: UserID, listId: FavoriteListID) async throws -> [Movie] {
        let movies = storedFavorites[userId]?[listId] ?? []
        favoritesByList[listId] = movies
        removeMembership(for: listId)
        for movie in movies {
            favoriteListsByMovie[movie.id, default: []].insert(listId)
        }
        favoritesByListSubject.send(favoritesByList)
        favoriteListsByMovieSubject.send(favoriteListsByMovie)
        return movies
    }

    public func favoriteListIds(userId: UserID, movieId: MovieID) async throws -> Set<FavoriteListID> {
        if let cached = favoriteListsByMovie[movieId] {
            return cached
        }
        let listIds = storedFavoriteListsByMovie[userId]?[movieId] ?? []
        if !listIds.isEmpty {
            favoriteListsByMovie[movieId] = listIds
            favoriteListsByMovieSubject.send(favoriteListsByMovie)
        }
        return listIds
    }

    public func addFavorite(userId: UserID, movie: MovieDetails, listId: FavoriteListID) async throws {
        var list = storedFavorites[userId] ?? [:]

        var movies = list[listId] ?? []
        if !movies.contains(where: { $0.id == movie.id }) {
            let item = Movie(id: movie.id, title: movie.title, year: nil, posterURL: movie.posterURL)
            movies.append(item)
        }
        list[listId] = movies
        storedFavorites[userId] = list
        var movieMap = storedFavoriteListsByMovie[userId] ?? [:]
        movieMap[movie.id, default: []].insert(listId)
        storedFavoriteListsByMovie[userId] = movieMap

        var cachedMovies = favoritesByList[listId] ?? []
        if !cachedMovies.contains(where: { $0.id == movie.id }) {
            cachedMovies.append(Movie(id: movie.id, title: movie.title, year: nil, posterURL: movie.posterURL))
        }
        favoritesByList[listId] = cachedMovies
        favoriteListsByMovie[movie.id, default: []].insert(listId)
        favoritesByListSubject.send(favoritesByList)
        favoriteListsByMovieSubject.send(favoriteListsByMovie)
    }

    public func removeFavorite(userId: UserID, movieId: MovieID, listId: FavoriteListID) async throws {
        storedFavorites[userId]?[listId]?.removeAll { $0.id == movieId }
        if var memberships = storedFavoriteListsByMovie[userId]?[movieId] {
            memberships.remove(listId)
            storedFavoriteListsByMovie[userId]?[movieId] = memberships.isEmpty ? nil : memberships
        }

        favoritesByList[listId]?.removeAll { $0.id == movieId }
        if var memberships = favoriteListsByMovie[movieId] {
            memberships.remove(listId)
            favoriteListsByMovie[movieId] = memberships.isEmpty ? nil : memberships
        }
        favoritesByListSubject.send(favoritesByList)
        favoriteListsByMovieSubject.send(favoriteListsByMovie)
    }

    public func removeFavorite(userId: UserID, movieId: MovieID) async throws {
        var list = storedFavorites[userId] ?? [:]
        for key in list.keys {
            list[key]?.removeAll { $0.id == movieId }
        }
        storedFavorites[userId] = list
        storedFavoriteListsByMovie[userId]?[movieId] = nil

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

    public func seedFavorites(_ movies: [Movie], for userId: UserID, listId: FavoriteListID) {
        var list = storedFavorites[userId] ?? [:]
        list[listId] = movies
        storedFavorites[userId] = list
        var movieMap = storedFavoriteListsByMovie[userId] ?? [:]
        for movie in movies {
            movieMap[movie.id, default: []].insert(listId)
        }
        storedFavoriteListsByMovie[userId] = movieMap
    }

    public func favoriteListId(userId: UserID, movieId: MovieID) async throws -> FavoriteListID? {
        try await favoriteListIds(userId: userId, movieId: movieId).first
    }

    private func removeMembership(for listId: FavoriteListID) {
        for movieId in Array(favoriteListsByMovie.keys) {
            guard var memberships = favoriteListsByMovie[movieId] else { continue }
            memberships.remove(listId)
            favoriteListsByMovie[movieId] = memberships.isEmpty ? nil : memberships
        }
    }
}
