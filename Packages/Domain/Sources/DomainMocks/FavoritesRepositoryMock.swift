import DomainModels
import DomainRepositories

@MainActor
public final class FavoritesRepositoryMock: FavoritesRepositoryProtocol {
    private var storedFavorites: [UserID: [FavoriteListID: [Movie]]] = [:]
    private var storedFavoriteListsByMovie: [UserID: [MovieID: Set<FavoriteListID>]] = [:]

    public init() {}

    public func fetchFavorites(userId: UserID, listId: FavoriteListID) async throws -> [Movie] {
        storedFavorites[userId]?[listId] ?? []
    }

    public func favoriteListIds(userId: UserID, movieId: MovieID) async throws -> Set<FavoriteListID> {
        storedFavoriteListsByMovie[userId]?[movieId] ?? []
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
    }

    public func removeFavorite(userId: UserID, movieId: MovieID, listId: FavoriteListID) async throws {
        storedFavorites[userId]?[listId]?.removeAll { $0.id == movieId }
        if var memberships = storedFavoriteListsByMovie[userId]?[movieId] {
            memberships.remove(listId)
            storedFavoriteListsByMovie[userId]?[movieId] = memberships.isEmpty ? nil : memberships
        }
    }

    public func removeFavorite(userId: UserID, movieId: MovieID) async throws {
        var list = storedFavorites[userId] ?? [:]
        for key in list.keys {
            list[key]?.removeAll { $0.id == movieId }
        }
        storedFavorites[userId] = list
        storedFavoriteListsByMovie[userId]?[movieId] = nil
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
}
