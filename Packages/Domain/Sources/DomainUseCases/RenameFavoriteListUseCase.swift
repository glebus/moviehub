import Foundation
import DomainModels
import DomainRepositories

@MainActor
public struct RenameFavoriteListUseCase {
    private let listsRepository: FavoriteListsRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol

    public init(
        listsRepository: FavoriteListsRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol
    ) {
        self.listsRepository = listsRepository
        self.profileRepository = profileRepository
    }

    public func rename(listId: FavoriteListID, name: String) async throws {
        let user = try requireCurrentUser(from: profileRepository)
        try await listsRepository.renameList(userId: user.id, listId: listId, name: name)
    }
}
