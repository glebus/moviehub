import Testing
import Domain

@MainActor
struct SessionInteractorTests {
    @Test
    func loginSetsCacheAndEmitsStream() async throws {
        let repo = ProfileRepositoryMock()
        let interactor = SessionInteractor(profileRepository: repo)
        var iterator = interactor.currentUserStream.makeAsyncIterator()

        _ = await iterator.next()
        let user = try await interactor.login(username: "  Alice  ")
        let emitted = await iterator.next() ?? nil

        #expect(interactor.currentUser() == user)
        #expect(emitted == user)
    }

    @Test
    func logoutEmitsNil() async throws {
        let repo = ProfileRepositoryMock()
        let interactor = SessionInteractor(profileRepository: repo)
        var iterator = interactor.currentUserStream.makeAsyncIterator()

        _ = await iterator.next()
        _ = try await interactor.login(username: "Bob")
        _ = await iterator.next()

        await interactor.logout()
        let emitted = await iterator.next() ?? nil

        #expect(emitted == nil)
    }
}
