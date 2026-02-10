import Testing
import Domain
import DomainMocks

@MainActor
struct SessionInteractorTests {
    @Test
    func loginSetsCacheAndEmitsStream() async throws {
        let repo = ProfileRepositoryMock()
        let interactor = SessionInteractor(profileRepository: repo)

        let loggedInUser = try await interactor.login(username: "  Alice  ")

        #expect(interactor.currentUser == loggedInUser)
    }

    @Test
    func logoutEmitsNil() async throws {
        let repo = ProfileRepositoryMock()
        let interactor = SessionInteractor(profileRepository: repo)
        _ = try await interactor.login(username: "Bob")

        await interactor.logout()

        #expect(interactor.currentUser == nil)
    }
}
