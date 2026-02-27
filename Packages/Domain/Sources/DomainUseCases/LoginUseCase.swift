import Foundation
import DomainModels
import DomainRepositories

@MainActor
public struct LoginUseCase {
    private let profileRepository: ProfileRepositoryProtocol
    private let favoriteListsRepository: FavoriteListsRepositoryProtocol

    public init(
        profileRepository: ProfileRepositoryProtocol,
        favoriteListsRepository: FavoriteListsRepositoryProtocol
    ) {
        self.profileRepository = profileRepository
        self.favoriteListsRepository = favoriteListsRepository
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
        profileRepository.setCurrentUser(user)
        _ = try await favoriteListsRepository.fetchLists(userId: user.id)
        return user
    }
}
