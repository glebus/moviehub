import Foundation
import DomainModels
import DomainRepositories

@MainActor
public struct HandleMovieDetailsFavoriteTapUseCase {
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

    public func handleTap(movieDetails: MovieDetails) async throws -> HandleMovieDetailsFavoriteTapResult {
        guard let user = profileRepository.currentUser else {
            return .requireAuth
        }

        let existingListIds = try await favoritesRepository.favoriteListIds(
            userId: user.id,
            movieId: movieDetails.id
        )
        if !existingListIds.isEmpty {
            try await favoritesRepository.removeFavorite(userId: user.id, movieId: movieDetails.id)
            return .removed
        }

        if favoriteListsRepository.lists.isEmpty {
            return .showCreateList
        }

        return .showPicker(movieDetails)
    }
}
