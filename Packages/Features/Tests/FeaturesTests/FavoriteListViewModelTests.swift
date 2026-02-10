import Foundation
import Testing
import Domain
import DomainMocks
import Router
import AuthButton
@testable import FavoriteList

@MainActor
struct FavoriteListViewModelTests {
    @Test
    func idleStateWhenNoUser() async {
        let router = AppRouterMock()
        let session = SessionInteractorMock(currentUser: nil)
        let listsRepository = FavoriteListsRepositoryMock()
        let listsInteractor = FavoriteListsInteractor(
            listsRepository: listsRepository,
            sessionInteractor: session
        )
        let authButtonBuilder = AuthButtonBuilder(sessionInteractor: session, router: router)
        let viewModel = FavoriteListViewModel(
            sessionInteractor: session,
            favoriteListsInteractor: listsInteractor,
            router: router,
            authButtonBuilder: authButtonBuilder
        )

        guard case .idle = viewModel.state else {
            fail("Expected idle state when no user")
            return
        }
    }

    @Test
    func loadedStateWhenUserAndFavoritesPresent() async {
        let router = AppRouterMock()
        let session = SessionInteractorMock(currentUser: nil)
        let listsRepository = FavoriteListsRepositoryMock()
        let listsInteractor = FavoriteListsInteractor(
            listsRepository: listsRepository,
            sessionInteractor: session
        )
        let authButtonBuilder = AuthButtonBuilder(sessionInteractor: session, router: router)
        let viewModel = FavoriteListViewModel(
            sessionInteractor: session,
            favoriteListsInteractor: listsInteractor,
            router: router,
            authButtonBuilder: authButtonBuilder
        )

        viewModel.currentUser = User(id: UserID("u1"), username: "alex")
        viewModel.lists = [
            FavoriteList(id: FavoriteListID("l1"), name: "Comedies", color: .mint, createdAt: Date()),
            FavoriteList(id: FavoriteListID("l2"), name: "Drama", color: .indigo, createdAt: Date())
        ]

        guard case .loaded(let items) = viewModel.state else {
            fail("Expected loaded state for lists")
            return
        }
        #expect(items.count == 2)
    }
}
