import Foundation
import Testing
import DomainModels
import DomainUseCases
import DomainMocks
import Coordinator
import AuthButton
@testable import FavoriteList

@MainActor
struct FavoriteListViewModelTests {
    @Test
    func idleStateWhenNoUser() async {
        let coordinator = CoordinatorMock()
        let session = SessionUseCaseMock(currentUser: nil)
        let favoriteListsUseCases = FavoriteListsUseCaseMock()
        let authButtonBuilder = AuthButtonBuilder(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            coordinator: coordinator
        )
        let viewModel = FavoriteListViewModel(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            favoriteListsStateUseCase: { favoriteListsUseCases.lists },
            favoriteListsSequenceUseCase: { favoriteListsUseCases.listsSequence },
            refreshFavoriteListsUseCase: { try await favoriteListsUseCases.refresh() },
            coordinator: coordinator,
            authButtonBuilder: authButtonBuilder
        )

        guard case .idle = viewModel.state else {
            fail("Expected idle state when no user")
            return
        }
    }

    @Test
    func loadedStateWhenUserAndFavoritesPresent() async {
        let coordinator = CoordinatorMock()
        let session = SessionUseCaseMock(currentUser: nil)
        let favoriteListsUseCases = FavoriteListsUseCaseMock()
        let authButtonBuilder = AuthButtonBuilder(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            coordinator: coordinator
        )
        let viewModel = FavoriteListViewModel(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            favoriteListsStateUseCase: { favoriteListsUseCases.lists },
            favoriteListsSequenceUseCase: { favoriteListsUseCases.listsSequence },
            refreshFavoriteListsUseCase: { try await favoriteListsUseCases.refresh() },
            coordinator: coordinator,
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
