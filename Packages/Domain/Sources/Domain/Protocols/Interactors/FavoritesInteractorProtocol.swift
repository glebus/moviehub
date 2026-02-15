@MainActor
public protocol FavoritesInteractorProtocol: Sendable, AnyObject {
    var favoritesByList: [FavoriteListID: [Movie]] { get }
    var favoriteListByMovie: [MovieID: FavoriteListID] { get }
    func refreshFavorites(listId: FavoriteListID) async throws
    func addFavorite(movie: MovieDetails, listId: FavoriteListID) async throws
    func removeFavorite(movieId: MovieID) async throws
    func favoriteListId(movieId: MovieID) async throws -> FavoriteListID?
}
