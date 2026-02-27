import Foundation
import DomainModels
import DomainRepositories

@MainActor
public struct LogoutUseCase {
    private let profileRepository: ProfileRepositoryProtocol
    private let favoriteListsRepository: FavoriteListsRepositoryProtocol

    public init(
        profileRepository: ProfileRepositoryProtocol,
        favoriteListsRepository: FavoriteListsRepositoryProtocol
    ) {
        self.profileRepository = profileRepository
        self.favoriteListsRepository = favoriteListsRepository
    }

    public func logout() async {
        favoriteListsRepository.clearLists()
        profileRepository.setCurrentUser(nil)
    }
}
