import Foundation
import DomainModels
import DomainRepositories

@MainActor
public struct CreateFavoriteListUseCase {
    private let listsRepository: FavoriteListsRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol

    public init(
        listsRepository: FavoriteListsRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol
    ) {
        self.listsRepository = listsRepository
        self.profileRepository = profileRepository
    }

    public func create(name: String, color: FavoriteListColor) async throws -> FavoriteList {
        let user = try requireCurrentUser(from: profileRepository)
        return try await listsRepository.createList(userId: user.id, name: name, color: color)
    }
}
