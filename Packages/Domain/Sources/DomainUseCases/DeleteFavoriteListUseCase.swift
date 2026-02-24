import Foundation
import DomainModels
import DomainRepositories

@MainActor
public struct DeleteFavoriteListUseCase {
    private let listsRepository: FavoriteListsRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol

    public init(
        listsRepository: FavoriteListsRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol
    ) {
        self.listsRepository = listsRepository
        self.profileRepository = profileRepository
    }

    public func delete(listId: FavoriteListID) async throws {
        let user = try requireCurrentUser(from: profileRepository)
        try await listsRepository.deleteList(userId: user.id, listId: listId)
    }
}
