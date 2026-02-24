import Foundation
import DomainModels
import DomainRepositories

@MainActor
public struct LookupFavoriteListUseCase {
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol

    public init(
        favoritesRepository: FavoritesRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol
    ) {
        self.favoritesRepository = favoritesRepository
        self.profileRepository = profileRepository
    }

    public func favoriteListId(movieId: MovieID) async throws -> FavoriteListID? {
        let user = try requireCurrentUser(from: profileRepository)
        return try await favoritesRepository.favoriteListId(userId: user.id, movieId: movieId)
    }
}
