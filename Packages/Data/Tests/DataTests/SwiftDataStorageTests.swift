import Testing
import DomainModels
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
        let list = try await storage.createList(userId: userId, name: "Comedies", color: .mint)
        let movie = MovieDetails(
            id: MovieID("m1"),
            title: "Movie",
            posterURL: nil,
            overview: nil,
            genres: [],
            imdbURL: nil
        )

        #expect(try await storage.favoriteListId(userId: userId, movieId: movie.id) == nil)

        try await storage.addFavorite(userId: userId, movie: movie, listId: list.id)

        #expect(try await storage.favoriteListId(userId: userId, movieId: movie.id) == list.id)
        let favorites = try await storage.fetchFavorites(userId: userId, listId: list.id)
        #expect(favorites.first?.id == movie.id)

        try await storage.removeFavorite(userId: userId, movieId: movie.id)
        #expect(try await storage.favoriteListId(userId: userId, movieId: movie.id) == nil)
    }

    @Test
    func favoriteListsCrud() async throws {
        let stack = SwiftDataStack(inMemory: true)
        let storage = SwiftDataStorage(container: stack.container)
        let userId = UserID("user-1")

        let created = try await storage.createList(userId: userId, name: "Comedies", color: .mint)
        var lists = try await storage.fetchLists(userId: userId)
        #expect(lists.contains(created))

        try await storage.renameList(userId: userId, listId: created.id, name: "Funny")
        lists = try await storage.fetchLists(userId: userId)
        #expect(lists.first?.name == "Funny")

        try await storage.deleteList(userId: userId, listId: created.id)
        lists = try await storage.fetchLists(userId: userId)
        #expect(lists.isEmpty)
    }
}
