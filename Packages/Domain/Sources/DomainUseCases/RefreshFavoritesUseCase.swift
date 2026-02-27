import Foundation
import DomainModels
import DomainRepositories

@MainActor
public struct RefreshFavoritesUseCase {
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol

    public init(
        favoritesRepository: FavoritesRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol
    ) {
        self.favoritesRepository = favoritesRepository
        self.profileRepository = profileRepository
    }

    public func refreshFavorites(listId: FavoriteListID) async throws -> [Movie] {
        let user = try requireCurrentUser(from: profileRepository)
        return try await favoritesRepository.fetchFavorites(userId: user.id, listId: listId)
    }
}
