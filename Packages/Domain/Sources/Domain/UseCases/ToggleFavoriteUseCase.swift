@MainActor
public protocol ToggleFavoriteUseCaseProtocol: Sendable {
    func toggle(movie: MovieDetails) async throws -> Bool
}

@MainActor
public final class ToggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol

    public init(
        profileRepository: ProfileRepositoryProtocol,
        favoritesRepository: FavoritesRepositoryProtocol
    ) {
        self.profileRepository = profileRepository
        self.favoritesRepository = favoritesRepository
    }

    public func toggle(movie: MovieDetails) async throws -> Bool {
        guard let user = profileRepository.currentUser() else {
            throw AuthRequiredError()
        }

        let userId = user.id
        let isFavorite = try await favoritesRepository.isFavorite(movieId: movie.id, userId: userId)

        if isFavorite {
            try await favoritesRepository.remove(movieId: movie.id, userId: userId)
            return false
        }

        try await favoritesRepository.add(movie: movie, userId: userId)
        return true
    }
}
