import Testing
import DomainMocks
import Router
@testable import Auth

@MainActor
struct AuthViewModelTests {
    @Test
    func loginWithEmptyUsernameShowsError() async {
        let router = AppRouterMock()
        let session = SessionUseCaseMock()
        let viewModel = AuthViewModel(loginUseCase: { try await session.login(username: $0) }, router: router)

        viewModel.username = " "
        await viewModel.login()

        guard case .error(let message) = viewModel.state else {
            fail("Expected error state for empty username")
            return
        }
        #expect(message == "Please enter a username")
    }

    @Test
    func loginSuccessDismissesSheet() async {
        let router = AppRouterMock()
        let session = SessionUseCaseMock()
        let viewModel = AuthViewModel(loginUseCase: { try await session.login(username: $0) }, router: router)

        viewModel.username = "Alex"
        await viewModel.login()

        #expect(viewModel.state == .success)
        #expect(router.didDismiss == true)
    }
}
