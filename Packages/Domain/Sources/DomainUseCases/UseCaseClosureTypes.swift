import Foundation
import DomainModels

public typealias CurrentUserReader = @MainActor () -> User?
public typealias CurrentUserSequenceSource = @MainActor () -> any AsyncSequence<User?, Never>
public typealias FavoriteListsReader = @MainActor () -> [FavoriteList]
public typealias FavoriteListsSequenceSource = @MainActor () -> any AsyncSequence<[FavoriteList], Never>
public typealias FavoritesByListReader = @MainActor () -> [FavoriteListID: [Movie]]
public typealias FavoritesByListSequenceSource = @MainActor () -> any AsyncSequence<[FavoriteListID: [Movie]], Never>
public typealias FavoriteListByMovieReader = @MainActor () -> [MovieID: FavoriteListID]
public typealias FavoriteListByMovieSequenceSource = @MainActor () -> any AsyncSequence<[MovieID: FavoriteListID], Never>
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
public typealias RemoveFavoriteAction = @MainActor (MovieID) async throws -> Void
public typealias LookupFavoriteListAction = @MainActor (MovieID) async throws -> FavoriteListID?
