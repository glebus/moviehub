import Foundation
import DomainModels
import DomainRepositories

@MainActor
public struct RefreshFavoriteListsUseCase {
    private let listsRepository: FavoriteListsRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol

    public init(
        listsRepository: FavoriteListsRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol
    ) {
        self.listsRepository = listsRepository
        self.profileRepository = profileRepository
    }

    public func refresh() async throws {
        let user = try requireCurrentUser(from: profileRepository)
        _ = try await listsRepository.fetchLists(userId: user.id)
    }
}
