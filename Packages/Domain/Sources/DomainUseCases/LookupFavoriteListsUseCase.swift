import Foundation
import DomainModels
import DomainRepositories

@MainActor
public struct LookupFavoriteListsUseCase {
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol

    public init(
        favoritesRepository: FavoritesRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol
    ) {
        self.favoritesRepository = favoritesRepository
        self.profileRepository = profileRepository
    }

    public func favoriteListIds(movieId: MovieID) async throws -> Set<FavoriteListID> {
        let user = try requireCurrentUser(from: profileRepository)
        return try await favoritesRepository.favoriteListIds(userId: user.id, movieId: movieId)
    }
}
