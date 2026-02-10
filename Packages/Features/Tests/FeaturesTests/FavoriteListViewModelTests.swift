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
        let favorites = FavoritesInteractorMock()
        let authButtonBuilder = AuthButtonBuilder(sessionInteractor: session, router: router)
        let viewModel = FavoriteListViewModel(
            sessionInteractor: session,
            favoritesInteractor: favorites,
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
        let favorites = FavoritesInteractorMock()
        let authButtonBuilder = AuthButtonBuilder(sessionInteractor: session, router: router)
        let viewModel = FavoriteListViewModel(
            sessionInteractor: session,
            favoritesInteractor: favorites,
            router: router,
            authButtonBuilder: authButtonBuilder
        )

        viewModel.currentUser = User(id: UserID("u1"), username: "alex")
        viewModel.favorites = [
            Movie(id: MovieID("m1"), title: "Fav 1", year: "2020", posterURL: nil),
            Movie(id: MovieID("m2"), title: "Fav 2", year: "2019", posterURL: nil)
        ]

        guard case .loaded(let items) = viewModel.state else {
            fail("Expected loaded state for favorites")
            return
        }
        #expect(items.count == 2)
    }
}
