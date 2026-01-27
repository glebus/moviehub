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

        let states = await recordChanges(count: 1, observe: { viewModel.state })

        guard case .loggedIn(let username) = viewModel.state else {
            fail("Expected loggedIn state for existing user")
            return
        }
        #expect(username == "alex")
        #expect(states.contains { if case .loggedIn = $0 { true } else { false } })
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

        _ = await recordChanges(count: 1, observe: { viewModel.state })

        let states = await recordChanges(count: 1, observe: { viewModel.state }) {
            viewModel.logoutTapped()
        }

        guard case .loggedOut = viewModel.state else {
            fail("Expected loggedOut state after logout")
            return
        }
        #expect(states.contains { if case .loggedOut = $0 { true } else { false } })
    }
}
