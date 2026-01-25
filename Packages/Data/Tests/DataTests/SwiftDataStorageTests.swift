import Testing
import Domain
@testable import Data

@MainActor
struct SwiftDataStorageTests {
    @Test
    func createAndFindUser() async throws {
        let stack = SwiftDataStack(inMemory: true)
        let storage = SwiftDataStorage(container: stack.container)

        let created = try await storage.createUser(username: "  Alice ")
        let found = try await storage.findUser(username: "alice")

        #expect(created.id == UserID("alice"))
        #expect(found == created)
    }

    @Test
    func favoritesCrud() async throws {
        let stack = SwiftDataStack(inMemory: true)
        let storage = SwiftDataStorage(container: stack.container)
        let userId = UserID("user-1")
        let movie = MovieDetails(
            id: MovieID("m1"),
            title: "Movie",
            posterURL: nil,
            overview: nil,
            genres: [],
            imdbURL: nil
        )

        #expect(try await storage.existsFavorite(userId: userId, movieId: movie.id) == false)

        try await storage.addFavorite(userId: userId, movie: movie)

        #expect(try await storage.existsFavorite(userId: userId, movieId: movie.id) == true)
        let favorites = try await storage.fetchFavorites(userId: userId)
        #expect(favorites.first?.id == movie.id)

        try await storage.removeFavorite(userId: userId, movieId: movie.id)
        #expect(try await storage.existsFavorite(userId: userId, movieId: movie.id) == false)
    }
}
