import Combine
import Observation
import DomainModels
import DomainUseCases
import DomainRepositories

@MainActor
@Observable
public final class FavoritesRepositoryMock: FavoritesRepositoryProtocol {
    private var storedFavorites: [UserID: [FavoriteListID: [Movie]]] = [:]
    private var storedFavoriteListByMovie: [UserID: [MovieID: FavoriteListID]] = [:]
    public private(set) var favoritesByList: [FavoriteListID: [Movie]] = [:]
    private let favoritesByListSubject = CurrentValueSubject<[FavoriteListID: [Movie]], Never>([:])
    public var favoritesByListSequence: any AsyncSequence<[FavoriteListID: [Movie]], Never> {
        favoritesByListSubject.values
    }
    public private(set) var favoriteListByMovie: [MovieID: FavoriteListID] = [:]
    private let favoriteListByMovieSubject = CurrentValueSubject<[MovieID: FavoriteListID], Never>([:])
    public var favoriteListByMovieSequence: any AsyncSequence<[MovieID: FavoriteListID], Never> {
        favoriteListByMovieSubject.values
    }

    public init() {}

    public func fetchFavorites(userId: UserID, listId: FavoriteListID) async throws -> [Movie] {
        let movies = storedFavorites[userId]?[listId] ?? []
        favoritesByList[listId] = movies
        favoriteListByMovie = favoriteListByMovie.filter { $0.value != listId }
        for movie in movies {
            favoriteListByMovie[movie.id] = listId
        }
        favoritesByListSubject.send(favoritesByList)
        favoriteListByMovieSubject.send(favoriteListByMovie)
        return movies
    }

    public func favoriteListId(userId: UserID, movieId: MovieID) async throws -> FavoriteListID? {
        if let cached = favoriteListByMovie[movieId] {
            return cached
        }
        let listId = storedFavoriteListByMovie[userId]?[movieId]
        if let listId {
            favoriteListByMovie[movieId] = listId
            favoriteListByMovieSubject.send(favoriteListByMovie)
        }
        return listId
    }

    public func addFavorite(userId: UserID, movie: MovieDetails, listId: FavoriteListID) async throws {
        var list = storedFavorites[userId] ?? [:]
        let existingListId = storedFavoriteListByMovie[userId]?[movie.id]
        if let existingListId, existingListId != listId {
            list[existingListId]?.removeAll { $0.id == movie.id }
        }

        var movies = list[listId] ?? []
        if !movies.contains(where: { $0.id == movie.id }) {
            let item = Movie(id: movie.id, title: movie.title, year: nil, posterURL: movie.posterURL)
            movies.append(item)
        }
        list[listId] = movies
        storedFavorites[userId] = list
        var movieMap = storedFavoriteListByMovie[userId] ?? [:]
        movieMap[movie.id] = listId
        storedFavoriteListByMovie[userId] = movieMap

        if let existingListId, existingListId != listId {
            favoritesByList[existingListId]?.removeAll { $0.id == movie.id }
        }
        var cachedMovies = favoritesByList[listId] ?? []
        if !cachedMovies.contains(where: { $0.id == movie.id }) {
            cachedMovies.append(Movie(id: movie.id, title: movie.title, year: nil, posterURL: movie.posterURL))
        }
        favoritesByList[listId] = cachedMovies
        favoriteListByMovie[movie.id] = listId
        favoritesByListSubject.send(favoritesByList)
        favoriteListByMovieSubject.send(favoriteListByMovie)
    }

    public func removeFavorite(userId: UserID, movieId: MovieID) async throws {
        var list = storedFavorites[userId] ?? [:]
        for key in list.keys {
            list[key]?.removeAll { $0.id == movieId }
        }
        storedFavorites[userId] = list
        storedFavoriteListByMovie[userId]?[movieId] = nil

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

    public func seedFavorites(_ movies: [Movie], for userId: UserID, listId: FavoriteListID) {
        var list = storedFavorites[userId] ?? [:]
        list[listId] = movies
        storedFavorites[userId] = list
        var movieMap = storedFavoriteListByMovie[userId] ?? [:]
        for movie in movies {
            movieMap[movie.id] = listId
        }
        storedFavoriteListByMovie[userId] = movieMap
    }
}
