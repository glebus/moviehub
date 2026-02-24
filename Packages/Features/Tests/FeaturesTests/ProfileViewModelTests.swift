import Testing
import DomainModels
import DomainUseCases
import DomainMocks
import Router
import AuthButton
import FavoriteListsManage
@testable import Profile

@MainActor
struct ProfileViewModelTests {
    @Test
    func updatesStateWhenUserLoggedIn() async {
        let router = AppRouterMock()
        let session = SessionUseCaseMock(currentUser: User(id: UserID("u1"), username: "alex"))
        let authButtonBuilder = AuthButtonBuilder(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            router: router
        )
        let favoriteListsUseCases = FavoriteListsUseCaseMock()
        let listsManageBuilder = FavoriteListsManageBuilder(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            favoriteListsStateUseCase: { favoriteListsUseCases.lists },
            favoriteListsSequenceUseCase: { favoriteListsUseCases.listsSequence },
            refreshFavoriteListsUseCase: { try await favoriteListsUseCases.refresh() },
            renameFavoriteListUseCase: { try await favoriteListsUseCases.rename(listId: $0, name: $1) },
            deleteFavoriteListUseCase: { try await favoriteListsUseCases.delete(listId: $0) },
            router: router
        )
        let viewModel = ProfileViewModel(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            logoutUseCase: { await session.logout() },
            router: router,
            authButtonBuilder: authButtonBuilder,
            favoriteListsManageBuilder: listsManageBuilder
        )

        guard case .loggedIn(let username) = viewModel.state else {
            fail("Expected loggedIn state for existing user")
            return
        }
        #expect(username == "alex")
    }

    @Test
    func logoutTransitionsToLoggedOut() async {
        let router = AppRouterMock()
        let session = SessionUseCaseMock(currentUser: User(id: UserID("u1"), username: "alex"))
        let authButtonBuilder = AuthButtonBuilder(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            router: router
        )
        let favoriteListsUseCases = FavoriteListsUseCaseMock()
        let listsManageBuilder = FavoriteListsManageBuilder(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            favoriteListsStateUseCase: { favoriteListsUseCases.lists },
            favoriteListsSequenceUseCase: { favoriteListsUseCases.listsSequence },
            refreshFavoriteListsUseCase: { try await favoriteListsUseCases.refresh() },
            renameFavoriteListUseCase: { try await favoriteListsUseCases.rename(listId: $0, name: $1) },
            deleteFavoriteListUseCase: { try await favoriteListsUseCases.delete(listId: $0) },
            router: router
        )
        let viewModel = ProfileViewModel(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            logoutUseCase: { await session.logout() },
            router: router,
            authButtonBuilder: authButtonBuilder,
            favoriteListsManageBuilder: listsManageBuilder
        )

        await viewModel.logout()

        guard case .loggedOut = viewModel.state else {
            fail("Expected loggedOut state after logout")
            return
        }
    }
}
