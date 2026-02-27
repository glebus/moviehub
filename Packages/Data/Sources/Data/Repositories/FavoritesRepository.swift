import DomainModels
import DomainRepositories

@MainActor
public final class FavoritesRepository: FavoritesRepositoryProtocol {
    private let storage: SwiftDataStorage

    public init(storage: SwiftDataStorage) {
        self.storage = storage
    }

    public func fetchFavorites(userId: UserID, listId: FavoriteListID) async throws -> [Movie] {
        try await storage.fetchFavorites(userId: userId, listId: listId)
    }

    public func favoriteListIds(userId: UserID, movieId: MovieID) async throws -> Set<FavoriteListID> {
        try await storage.favoriteListIds(userId: userId, movieId: movieId)
    }

    public func addFavorite(userId: UserID, movie: MovieDetails, listId: FavoriteListID) async throws {
        try await storage.addFavorite(userId: userId, movie: movie, listId: listId)
    }

    public func removeFavorite(userId: UserID, movieId: MovieID, listId: FavoriteListID) async throws {
        try await storage.removeFavorite(userId: userId, movieId: movieId, listId: listId)
    }

    public func removeFavorite(userId: UserID, movieId: MovieID) async throws {
        try await storage.removeFavorite(userId: userId, movieId: movieId)
    }
}
