import Testing
import DomainMocks
import Coordinator
@testable import Auth

@MainActor
struct AuthViewModelTests {
    @Test
    func loginWithEmptyUsernameShowsError() async {
        let coordinator = AppCoordinatorMock()
        let session = SessionUseCaseMock()
        let viewModel = AuthViewModel(loginUseCase: { try await session.login(username: $0) }, coordinator: coordinator)

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
        let coordinator = AppCoordinatorMock()
        let session = SessionUseCaseMock()
        let viewModel = AuthViewModel(loginUseCase: { try await session.login(username: $0) }, coordinator: coordinator)

        viewModel.username = "Alex"
        await viewModel.login()

        #expect(viewModel.state == .success)
        #expect(coordinator.didDismiss == true)
    }
}
