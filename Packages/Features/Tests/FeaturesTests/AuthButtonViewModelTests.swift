import Testing
import DomainModels
import DomainUseCases
import DomainMocks
import Coordinator
@testable import AuthButton

@MainActor
struct AuthButtonViewModelTests {
    @Test
    func titleUpdatesFromSession() async {
        let coordinator = CoordinatorMock()
        let user = User(id: UserID("u1"), username: "alex")
        let session = SessionUseCaseMock(currentUser: user)
        let viewModel = AuthButtonViewModel(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            coordinator: coordinator
        )

        #expect(viewModel.title == "alex")
    }

    @Test
    func tappingWhenLoggedOutPresentsAuth() async {
        let coordinator = CoordinatorMock()
        let session = SessionUseCaseMock(currentUser: nil)
        let viewModel = AuthButtonViewModel(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            coordinator: coordinator
        )

        viewModel.tapped()

        #expect(coordinator.presentedDestination == .auth)
    }

    @Test
    func tappingWhenLoggedInSelectsProfileTab() async {
        let coordinator = CoordinatorMock()
        let user = User(id: UserID("u1"), username: "alex")
        let session = SessionUseCaseMock(currentUser: user)
        let viewModel = AuthButtonViewModel(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            coordinator: coordinator
        )

        viewModel.tapped()

        #expect(coordinator.selectedTab == .profile)
    }
}
