import Testing
import DomainMocks
import Router
@testable import Auth

@MainActor
struct AuthViewModelTests {
    @Test
    func loginWithEmptyUsernameShowsError() async {
        let router = AppRouterMock()
        let session = SessionInteractorMock()
        let viewModel = AuthViewModel(sessionInteractor: session, router: router)

        viewModel.username = " "
        let states = await recordChanges(count: 1, observe: { viewModel.state }) {
            viewModel.loginTapped()
        }

        guard case .error(let message) = states.last else {
            fail("Expected error state for empty username")
            return
        }
        #expect(message == "Please enter a username")
    }

    @Test
    func loginSuccessDismissesSheet() async {
        let router = AppRouterMock()
        let session = SessionInteractorMock()
        let viewModel = AuthViewModel(sessionInteractor: session, router: router)

        viewModel.username = "Alex"
        let states = await recordChanges(count: 2, observe: { viewModel.state }) {
            viewModel.loginTapped()
        }

        #expect(states.contains(.success))
        #expect(router.didDismissSheet == true)
    }
}
