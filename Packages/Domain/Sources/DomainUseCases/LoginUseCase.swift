import Foundation
import DomainModels
import DomainRepositories

@MainActor
public struct LoginUseCase {
    private let profileRepository: ProfileRepositoryProtocol
    private let favoriteListsRepository: FavoriteListsRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol

    public init(
        profileRepository: ProfileRepositoryProtocol,
        favoriteListsRepository: FavoriteListsRepositoryProtocol,
        favoritesRepository: FavoritesRepositoryProtocol
    ) {
        self.profileRepository = profileRepository
        self.favoriteListsRepository = favoriteListsRepository
        self.favoritesRepository = favoritesRepository
    }

    public func login(username: String) async throws -> User {
        let normalized = UsernameNormalizer.normalize(username)
        let user: User
        if let existing = try await profileRepository.findUser(username: normalized) {
            user = existing
        } else {
            user = try await profileRepository.createUser(username: normalized)
        }

        // Reset user-scoped caches before exposing the new session.
        favoriteListsRepository.clearLists()
        favoritesRepository.clearCaches()
        profileRepository.setCurrentUser(user)
        _ = try await favoriteListsRepository.fetchLists(userId: user.id)
        return user
    }
}
