import DomainModels

@MainActor
public protocol FavoritesRepositoryProtocol: Sendable {
    var favoritesByList: [FavoriteListID: [Movie]] { get }
    var favoritesByListSequence: any AsyncSequence<[FavoriteListID: [Movie]], Never> { get }
    var favoriteListsByMovie: [MovieID: Set<FavoriteListID>] { get }
    var favoriteListsByMovieSequence: any AsyncSequence<[MovieID: Set<FavoriteListID>], Never> { get }
    func fetchFavorites(userId: UserID, listId: FavoriteListID) async throws -> [Movie]
    func favoriteListIds(userId: UserID, movieId: MovieID) async throws -> Set<FavoriteListID>
    func addFavorite(userId: UserID, movie: MovieDetails, listId: FavoriteListID) async throws
    func removeFavorite(userId: UserID, movieId: MovieID, listId: FavoriteListID) async throws
    func removeFavorite(userId: UserID, movieId: MovieID) async throws
    func clearCaches()
}
