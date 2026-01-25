@MainActor
public protocol FavoritesRepositoryProtocol: Sendable {
    func favorites(userId: UserID) async throws -> [Movie]
    func favoritesStream(userId: UserID) -> AsyncStream<[Movie]>

    func isFavorite(movieId: MovieID, userId: UserID) async throws -> Bool
    func add(movie: MovieDetails, userId: UserID) async throws
    func remove(movieId: MovieID, userId: UserID) async throws
}
