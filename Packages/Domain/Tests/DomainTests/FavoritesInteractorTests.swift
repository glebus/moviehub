import Testing
import Domain

@MainActor
struct FavoritesInteractorTests {
    @Test
    func streamEmitsOnSessionChange() async throws {
        let profileRepo = ProfileRepositoryMock()
        let favoritesRepo = FavoritesRepositoryMock()
        let session = SessionInteractor(profileRepository: profileRepo)
        let interactor = FavoritesInteractor(favoritesRepository: favoritesRepo, sessionInteractor: session)

        var iterator = interactor.favoritesStream.makeAsyncIterator()
        let initial = await iterator.next() ?? []
        #expect(initial == [])

        let user = try await session.login(username: "user")
        let seeded = Movie(id: MovieID("m1"), title: "Movie", year: nil, posterURL: nil)
        await favoritesRepo.seedFavorites([seeded], for: user.id)

        try await interactor.refresh()
        var refreshed = await iterator.next() ?? []
        if refreshed.isEmpty {
            refreshed = await iterator.next() ?? []
        }
        #expect(refreshed == [seeded])

        await session.logout()
        var cleared = await iterator.next() ?? [seeded]
        if cleared == [seeded] {
            cleared = await iterator.next() ?? [seeded]
        }
        #expect(cleared == [])
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
