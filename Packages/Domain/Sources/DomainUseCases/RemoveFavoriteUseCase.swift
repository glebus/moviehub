import Foundation
import DomainModels
import DomainRepositories

@MainActor
public struct RemoveFavoriteUseCase {
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol

    public init(
        favoritesRepository: FavoritesRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol
    ) {
        self.favoritesRepository = favoritesRepository
        self.profileRepository = profileRepository
    }

    public func removeFavorite(movieId: MovieID) async throws {
        let user = try requireCurrentUser(from: profileRepository)
        try await favoritesRepository.removeFavorite(userId: user.id, movieId: movieId)
    }
}
