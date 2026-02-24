import Foundation
import DomainModels
import DomainRepositories

@MainActor
public struct AddFavoriteUseCase {
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol

    public init(
        favoritesRepository: FavoritesRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol
    ) {
        self.favoritesRepository = favoritesRepository
        self.profileRepository = profileRepository
    }

    public func addFavorite(movie: MovieDetails, listId: FavoriteListID) async throws {
        let user = try requireCurrentUser(from: profileRepository)
        try await favoritesRepository.addFavorite(userId: user.id, movie: movie, listId: listId)
    }
}
