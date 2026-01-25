import Testing
import Domain
@testable import Data

struct FavoritesRepositoryTests {
    @Test
    @MainActor
    func favoritesStreamEmitsInitialEmptyList() async throws {
        let stack = SwiftDataStack(inMemory: true)
        let storage = SwiftDataStorage(container: stack.container)
        let repository = FavoritesRepository(storage: storage)
        let userId = UserID("user-1")

        var iterator = repository.favoritesStream(userId: userId).makeAsyncIterator()
        let first = await iterator.next()

        #expect(first == [])
    }

    @Test
    @MainActor
    func addFavoriteUpdatesStreamAndSnapshot() async throws {
        let stack = SwiftDataStack(inMemory: true)
        let storage = SwiftDataStorage(container: stack.container)
        let repository = FavoritesRepository(storage: storage)
        let userId = UserID("user-1")
        let movie = MovieDetailsStub.make(id: "movie-1")

        var iterator = repository.favoritesStream(userId: userId).makeAsyncIterator()
        _ = await iterator.next()

        try await repository.add(movie: movie, userId: userId)

        let updated = await iterator.next()
        #expect(updated?.count == 1)
        #expect(updated?.first?.id == MovieID("movie-1"))

        let snapshot = try await repository.favorites(userId: userId)
        #expect(snapshot.count == 1)
    }

    @Test
    @MainActor
    func removeFavoriteUpdatesStreamAndSnapshot() async throws {
        let stack = SwiftDataStack(inMemory: true)
        let storage = SwiftDataStorage(container: stack.container)
        let repository = FavoritesRepository(storage: storage)
        let userId = UserID("user-1")
        let movie = MovieDetailsStub.make(id: "movie-1")

        var iterator = repository.favoritesStream(userId: userId).makeAsyncIterator()
        _ = await iterator.next()

        try await repository.add(movie: movie, userId: userId)
        _ = await iterator.next()

        try await repository.remove(movieId: MovieID("movie-1"), userId: userId)

        let updated = await iterator.next()
        #expect(updated == [])

        let snapshot = try await repository.favorites(userId: userId)
        #expect(snapshot.isEmpty)
    }
}
