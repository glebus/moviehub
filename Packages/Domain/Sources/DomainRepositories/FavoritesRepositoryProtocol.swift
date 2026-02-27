import DomainModels

@MainActor
public protocol FavoritesRepositoryProtocol: Sendable {
    func fetchFavorites(userId: UserID, listId: FavoriteListID) async throws -> [Movie]
    func favoriteListIds(userId: UserID, movieId: MovieID) async throws -> Set<FavoriteListID>
    func addFavorite(userId: UserID, movie: MovieDetails, listId: FavoriteListID) async throws
    func removeFavorite(userId: UserID, movieId: MovieID, listId: FavoriteListID) async throws
    func removeFavorite(userId: UserID, movieId: MovieID) async throws
}
