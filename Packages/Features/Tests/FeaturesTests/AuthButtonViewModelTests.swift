import Testing
import DomainModels
import DomainUseCases
import DomainMocks
import Router
@testable import AuthButton

@MainActor
struct AuthButtonViewModelTests {
    @Test
    func titleUpdatesFromSession() async {
        let router = AppRouterMock()
        let user = User(id: UserID("u1"), username: "alex")
        let session = SessionUseCaseMock(currentUser: user)
        let viewModel = AuthButtonViewModel(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            router: router
        )

        #expect(viewModel.title == "alex")
    }

    @Test
    func tappingWhenLoggedOutPresentsAuth() async {
        let router = AppRouterMock()
        let session = SessionUseCaseMock(currentUser: nil)
        let viewModel = AuthButtonViewModel(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            router: router
        )

        viewModel.tapped()

        #expect(router.lastSheetDestination == .auth)
    }

    @Test
    func tappingWhenLoggedInSelectsProfileTab() async {
        let router = AppRouterMock()
        let user = User(id: UserID("u1"), username: "alex")
        let session = SessionUseCaseMock(currentUser: user)
        let viewModel = AuthButtonViewModel(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            router: router
        )

        viewModel.tapped()

        #expect(router.selectedTab == .profile)
    }
}
