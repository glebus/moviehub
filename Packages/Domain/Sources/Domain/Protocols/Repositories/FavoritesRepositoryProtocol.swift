public protocol FavoritesRepositoryProtocol: Sendable {
    func fetchFavorites(userId: UserID) async throws -> [Movie]
    func existsFavorite(userId: UserID, movieId: MovieID) async throws -> Bool
    func addFavorite(userId: UserID, movie: MovieDetails) async throws
    func removeFavorite(userId: UserID, movieId: MovieID) async throws
}
