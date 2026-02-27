import Foundation
import DomainModels

public typealias CurrentUserReader = @MainActor () -> User?
public typealias CurrentUserSequenceSource = @MainActor () -> any AsyncSequence<User?, Never>
public typealias FavoriteListsReader = @MainActor () -> [FavoriteList]
public typealias FavoriteListsSequenceSource = @MainActor () -> any AsyncSequence<[FavoriteList], Never>
public typealias FavoritesByListReader = @MainActor () -> [FavoriteListID: [Movie]]
public typealias FavoritesByListSequenceSource = @MainActor () -> any AsyncSequence<[FavoriteListID: [Movie]], Never>
public typealias SearchMoviesAction = @MainActor (String) async throws -> [Movie]
public typealias MovieDetailsAction = @MainActor (MovieID) async throws -> MovieDetails
public typealias LoginAction = @MainActor (String) async throws -> User
public typealias LogoutAction = @MainActor () async -> Void
public typealias RefreshFavoriteListsAction = @MainActor () async throws -> Void
public typealias CreateFavoriteListAction = @MainActor (String, FavoriteListColor) async throws -> FavoriteList
public typealias RenameFavoriteListAction = @MainActor (FavoriteListID, String) async throws -> Void
public typealias DeleteFavoriteListAction = @MainActor (FavoriteListID) async throws -> Void
public typealias RefreshFavoritesAction = @MainActor (FavoriteListID) async throws -> Void
public typealias AddFavoriteAction = @MainActor (MovieDetails, FavoriteListID) async throws -> Void
public typealias RemoveFavoriteFromListAction = @MainActor (MovieID, FavoriteListID) async throws -> Void
public typealias LookupCurrentUserFavoriteListsAction = @MainActor (MovieID) async throws -> LookupCurrentUserFavoriteListsResult
public typealias HandleMovieDetailsFavoriteTapAction = @MainActor (MovieDetails) async throws -> HandleMovieDetailsFavoriteTapResult

public enum LookupCurrentUserFavoriteListsResult: Sendable {
    case requireAuth
    case favoriteListIDs(Set<FavoriteListID>)
}

public enum HandleMovieDetailsFavoriteTapResult: Sendable {
    case requireAuth
    case showCreateList
    case showPicker(MovieDetails)
    case removed
}
