import Testing
@testable import Domain
import DomainMocks

@MainActor
struct FavoritesInteractorTests {
    @Test
    func refreshLoadsFavorites() async throws {
        let profileRepo = ProfileRepositoryMock()
        let favoritesRepo = FavoritesRepositoryMock()
        let session = SessionInteractor(profileRepository: profileRepo)
        let interactor = FavoritesInteractor(favoritesRepository: favoritesRepo, sessionInteractor: session)

        #expect(interactor.favorites == [])

        let user = try await session.login(username: "user")
        let seeded = Movie(id: MovieID("m1"), title: "Movie", year: nil, posterURL: nil)
        await favoritesRepo.seedFavorites([seeded], for: user.id)

        try await interactor.refresh()
        #expect(interactor.favorites == [seeded])
    }

    @Test
    func handleSessionChangeClearsFavoritesOnLogout() async throws {
        let profileRepo = ProfileRepositoryMock()
        let favoritesRepo = FavoritesRepositoryMock()
        let session = SessionInteractor(profileRepository: profileRepo)
        let interactor = FavoritesInteractor(favoritesRepository: favoritesRepo, sessionInteractor: session)

        let user = try await session.login(username: "user")
        let seeded = Movie(id: MovieID("m1"), title: "Movie", year: nil, posterURL: nil)
        await favoritesRepo.seedFavorites([seeded], for: user.id)
        try await interactor.refresh()
        #expect(interactor.favorites == [seeded])

        await interactor.handleSessionChange(nil)
        #expect(interactor.favorites == [])
    }

    @Test
    func toggleAddsAndRemoves() async throws {
        let profileRepo = ProfileRepositoryMock()
        let favoritesRepo = FavoritesRepositoryMock()
        let session = SessionInteractor(profileRepository: profileRepo)
        let interactor = FavoritesInteractor(favoritesRepository: favoritesRepo, sessionInteractor: session)

        _ = try await session.login(username: "user")

        let details = MovieDetails(
            id: MovieID("m1"),
            title: "Movie",
            posterURL: nil,
            overview: nil,
            genres: [],
            imdbURL: nil
        )

        let added = try await interactor.toggle(movie: details)
        #expect(added == true)
        #expect(interactor.isFavorite(movieId: details.id) == true)

        let removed = try await interactor.toggle(movie: details)
        #expect(removed == false)
        #expect(interactor.isFavorite(movieId: details.id) == false)
    }
}
