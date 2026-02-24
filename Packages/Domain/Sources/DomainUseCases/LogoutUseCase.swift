import Foundation
import DomainModels
import DomainRepositories

@MainActor
public struct LogoutUseCase {
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

    public func logout() async {
        favoritesRepository.clearCaches()
        favoriteListsRepository.clearLists()
        profileRepository.setCurrentUser(nil)
    }
}
