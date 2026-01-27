@MainActor
public protocol FavoritesInteractorProtocol: Sendable {
    func favorites() -> [Movie]
    var favoritesStream: AsyncStream<[Movie]> { get }
    func refresh() async throws
    func toggle(movie: MovieDetails) async throws -> Bool
    func isFavorite(movieId: MovieID) -> Bool
}
