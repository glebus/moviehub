import DomainModels

@MainActor
public protocol FavoritesRepositoryProtocol: Sendable {
    var favoritesByList: [FavoriteListID: [Movie]] { get }
    var favoritesByListSequence: any AsyncSequence<[FavoriteListID: [Movie]], Never> { get }
    var favoriteListByMovie: [MovieID: FavoriteListID] { get }
    var favoriteListByMovieSequence: any AsyncSequence<[MovieID: FavoriteListID], Never> { get }
    func fetchFavorites(userId: UserID, listId: FavoriteListID) async throws -> [Movie]
    func favoriteListId(userId: UserID, movieId: MovieID) async throws -> FavoriteListID?
    func addFavorite(userId: UserID, movie: MovieDetails, listId: FavoriteListID) async throws
    func removeFavorite(userId: UserID, movieId: MovieID) async throws
    func clearCaches()
}
