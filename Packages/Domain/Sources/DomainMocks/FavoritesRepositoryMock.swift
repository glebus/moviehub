import Domain

public actor FavoritesRepositoryMock: FavoritesRepositoryProtocol {
    private var favorites: [UserID: [FavoriteListID: [Movie]]] = [:]
    private var favoriteListByMovie: [UserID: [MovieID: FavoriteListID]] = [:]

    public init() {}

    public func fetchFavorites(userId: UserID, listId: FavoriteListID) async throws -> [Movie] {
        favorites[userId]?[listId] ?? []
    }

    public func favoriteListId(userId: UserID, movieId: MovieID) async throws -> FavoriteListID? {
        favoriteListByMovie[userId]?[movieId]
    }

    public func addFavorite(userId: UserID, movie: MovieDetails, listId: FavoriteListID) async throws {
        var list = favorites[userId] ?? [:]
        let existingListId = favoriteListByMovie[userId]?[movie.id]
        if let existingListId, existingListId != listId {
            list[existingListId]?.removeAll { $0.id == movie.id }
        }

        var movies = list[listId] ?? []
        if !movies.contains(where: { $0.id == movie.id }) {
            let item = Movie(id: movie.id, title: movie.title, year: nil, posterURL: movie.posterURL)
            movies.append(item)
        }
        list[listId] = movies
        favorites[userId] = list
        var movieMap = favoriteListByMovie[userId] ?? [:]
        movieMap[movie.id] = listId
        favoriteListByMovie[userId] = movieMap
    }

    public func removeFavorite(userId: UserID, movieId: MovieID) async throws {
        var list = favorites[userId] ?? [:]
        for key in list.keys {
            list[key]?.removeAll { $0.id == movieId }
        }
        favorites[userId] = list
        favoriteListByMovie[userId]?[movieId] = nil
    }

    public func seedFavorites(_ movies: [Movie], for userId: UserID, listId: FavoriteListID) {
        var list = favorites[userId] ?? [:]
        list[listId] = movies
        favorites[userId] = list
        var movieMap = favoriteListByMovie[userId] ?? [:]
        for movie in movies {
            movieMap[movie.id] = listId
        }
        favoriteListByMovie[userId] = movieMap
    }
}
