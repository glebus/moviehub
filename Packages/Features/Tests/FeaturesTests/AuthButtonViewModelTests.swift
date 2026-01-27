import Testing
import Domain
import DomainMocks
import Router
@testable import AuthButton

@MainActor
struct AuthButtonViewModelTests {
    @Test
    func titleUpdatesFromSession() async {
        let router = AppRouterMock()
        let user = User(id: UserID("u1"), username: "alex")
        let session = SessionInteractorMock(currentUser: user)
        let viewModel = AuthButtonViewModel(sessionInteractor: session, router: router)

        let titles = await recordChanges(count: 1, observe: { viewModel.title })

        #expect(titles.last == "alex")
    }

    @Test
    func tappingWhenLoggedOutPresentsAuth() async {
        let router = AppRouterMock()
        let session = SessionInteractorMock(currentUser: nil)
        let viewModel = AuthButtonViewModel(sessionInteractor: session, router: router)

        viewModel.tapped()

        #expect(router.lastSheetDestination == .auth)
    }

    @Test
    func tappingWhenLoggedInSelectsProfileTab() async {
        let router = AppRouterMock()
        let user = User(id: UserID("u1"), username: "alex")
        let session = SessionInteractorMock(currentUser: user)
        let viewModel = AuthButtonViewModel(sessionInteractor: session, router: router)

        _ = await recordChanges(count: 1, observe: { viewModel.title })

        viewModel.tapped()

        #expect(router.selectedTab == .profile)
    }
}
