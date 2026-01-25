import Testing
@testable import Domain

struct ToggleFavoriteUseCaseTests {
    @Test
    @MainActor
    func throwsWhenNotAuthenticated() async {
        let profile = ProfileRepositoryMock()
        profile.user = nil
        let favorites = FavoritesRepositoryMock()
        let useCase = ToggleFavoriteUseCase(profileRepository: profile, favoritesRepository: favorites)
        let movie = MovieDetails(
            id: MovieID("movie-1"),
            title: "Test",
            posterURL: nil,
            overview: nil,
            genres: [],
            imdbURL: nil
        )

        await #expect(throws: AuthRequiredError.self) {
            _ = try await useCase.toggle(movie: movie)
        }
    }

    @Test
    @MainActor
    func addsWhenNotFavorite() async throws {
        let profile = ProfileRepositoryMock()
        profile.user = User(id: UserID("user-1"), username: "test")
        let favorites = FavoritesRepositoryMock()
        let useCase = ToggleFavoriteUseCase(profileRepository: profile, favoritesRepository: favorites)
        let movie = MovieDetails(
            id: MovieID("movie-1"),
            title: "Test",
            posterURL: nil,
            overview: nil,
            genres: [],
            imdbURL: nil
        )

        let isFavorite = try await useCase.toggle(movie: movie)

        #expect(isFavorite)
        #expect(favorites.favorites.contains(movie.id))
    }

    @Test
    @MainActor
    func removesWhenAlreadyFavorite() async throws {
        let profile = ProfileRepositoryMock()
        profile.user = User(id: UserID("user-1"), username: "test")
        let favorites = FavoritesRepositoryMock()
        favorites.favorites = [MovieID("movie-1")]
        let useCase = ToggleFavoriteUseCase(profileRepository: profile, favoritesRepository: favorites)
        let movie = MovieDetails(
            id: MovieID("movie-1"),
            title: "Test",
            posterURL: nil,
            overview: nil,
            genres: [],
            imdbURL: nil
        )

        let isFavorite = try await useCase.toggle(movie: movie)

        #expect(!isFavorite)
        #expect(!favorites.favorites.contains(movie.id))
    }
}
