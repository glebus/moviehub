public protocol FavoritesRepositoryProtocol: Sendable {
    func fetchFavorites(userId: UserID, listId: FavoriteListID) async throws -> [Movie]
    func favoriteListId(userId: UserID, movieId: MovieID) async throws -> FavoriteListID?
    func addFavorite(userId: UserID, movie: MovieDetails, listId: FavoriteListID) async throws
    func removeFavorite(userId: UserID, movieId: MovieID) async throws
}
