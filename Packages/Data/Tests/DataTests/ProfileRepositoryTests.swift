import Testing
import Domain
@testable import Data

struct ProfileRepositoryTests {
    @Test
    @MainActor
    func loginCreatesUserIfMissing() async throws {
        let stack = SwiftDataStack(inMemory: true)
        let storage = SwiftDataStorage(container: stack.container)
        let repository = ProfileRepository(storage: storage)

        let user = try await repository.login(username: "NewUser")

        #expect(user.username == "newuser")
        #expect(user.id.rawValue == "newuser")
    }

    @Test
    @MainActor
    func loginReturnsExistingUser() async throws {
        let stack = SwiftDataStack(inMemory: true)
        let storage = SwiftDataStorage(container: stack.container)
        let repository = ProfileRepository(storage: storage)

        let first = try await repository.login(username: "Existing")
        let second = try await repository.login(username: "Existing")

        #expect(first.id == second.id)
        #expect(first.username == second.username)
    }

    @Test
    @MainActor
    func streamEmitsOnLoginAndLogout() async throws {
        let stack = SwiftDataStack(inMemory: true)
        let storage = SwiftDataStorage(container: stack.container)
        let repository = ProfileRepository(storage: storage)

        var iterator = repository.currentUserStream.makeAsyncIterator()

        let user = try await repository.login(username: "StreamUser")
        let first = await iterator.next() ?? nil
        #expect(first == user)

        await repository.logout()
        let second = await iterator.next() ?? nil
        #expect(second == nil)
    }
}
