import Testing
import Domain
import DomainMocks
import Router
import AuthButton
@testable import FavoriteList

@MainActor
struct FavoriteListViewModelTests {
    @Test
    func loggedOutStateWhenNoUser() async {
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

        let states = await recordChanges(count: 0, observe: { viewModel.state })

        guard case .loggedOut = viewModel.state else {
            fail("Expected loggedOut state when no user")
            return
        }
        #expect(states.contains { if case .loggedOut = $0 { true } else { false } })
    }

    @Test
    func loadsFavoritesWhenUserLoggedIn() async {
        let router = AppRouterMock()
        let session = SessionInteractorMock(currentUser: nil)
        let favorites = FavoritesInteractorMock(
            favorites: [
                Movie(id: MovieID("m1"), title: "Fav 1", year: "2020", posterURL: nil),
                Movie(id: MovieID("m2"), title: "Fav 2", year: "2019", posterURL: nil)
            ]
        )
        let authButtonBuilder = AuthButtonBuilder(sessionInteractor: session, router: router)
        let viewModel = FavoriteListViewModel(
            sessionInteractor: session,
            favoritesInteractor: favorites,
            router: router,
            authButtonBuilder: authButtonBuilder
        )

        let states = await recordChanges(count: 2, observe: { viewModel.state }) {
            Task {
                _ = try? await session.login(username: "alex")
                try? await favorites.refresh()
            }
        }

        guard case .loaded(let items) = viewModel.state else {
            fail("Expected loaded state for favorites")
            return
        }
        #expect(items.count == 2)
        #expect(states.contains { if case .loaded = $0 { true } else { false } })
    }
}
