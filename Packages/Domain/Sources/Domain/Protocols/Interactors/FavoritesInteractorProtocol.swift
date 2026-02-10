@MainActor
public protocol FavoritesInteractorProtocol: Sendable, AnyObject {
    var favorites: [Movie] { get }
    func refresh() async throws
    func toggle(movie: MovieDetails) async throws -> Bool
    func isFavorite(movieId: MovieID) -> Bool
}
