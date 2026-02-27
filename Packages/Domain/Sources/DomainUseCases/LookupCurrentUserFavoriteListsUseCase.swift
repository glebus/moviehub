import Foundation
import DomainModels
import DomainRepositories

@MainActor
public struct LookupCurrentUserFavoriteListsUseCase {
    private let profileRepository: ProfileRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol

    public init(
        profileRepository: ProfileRepositoryProtocol,
        favoritesRepository: FavoritesRepositoryProtocol
    ) {
        self.profileRepository = profileRepository
        self.favoritesRepository = favoritesRepository
    }

    public func favoriteListIds(movieId: MovieID) async throws -> LookupCurrentUserFavoriteListsResult {
        guard let user = profileRepository.currentUser else {
            return .requireAuth
        }

        let listIds = try await favoritesRepository.favoriteListIds(userId: user.id, movieId: movieId)
        return .favoriteListIDs(listIds)
    }
}
