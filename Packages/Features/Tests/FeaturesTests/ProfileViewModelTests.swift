import Testing
import Domain
import DomainMocks
import Router
import AuthButton
@testable import Profile

@MainActor
struct ProfileViewModelTests {
    @Test
    func updatesStateWhenUserLoggedIn() async {
        let router = AppRouterMock()
        let session = SessionInteractorMock(currentUser: User(id: UserID("u1"), username: "alex"))
        let authButtonBuilder = AuthButtonBuilder(sessionInteractor: session, router: router)
        let viewModel = ProfileViewModel(
            sessionInteractor: session,
            router: router,
            authButtonBuilder: authButtonBuilder
        )

        guard case .loggedIn(let username) = viewModel.state else {
            fail("Expected loggedIn state for existing user")
            return
        }
        #expect(username == "alex")
    }

    @Test
    func logoutTransitionsToLoggedOut() async {
        let router = AppRouterMock()
        let session = SessionInteractorMock(currentUser: User(id: UserID("u1"), username: "alex"))
        let authButtonBuilder = AuthButtonBuilder(sessionInteractor: session, router: router)
        let viewModel = ProfileViewModel(
            sessionInteractor: session,
            router: router,
            authButtonBuilder: authButtonBuilder
        )

        await viewModel.logout()

        guard case .loggedOut = viewModel.state else {
            fail("Expected loggedOut state after logout")
            return
        }
    }
}
