import Foundation
import Testing
import DomainModels
import Coordinator
@testable import FavoriteListDetails

@MainActor
struct FavoriteListDetailsViewModelTests {
    @Test
    func addMoviePresentsAddMoviesFlowForCurrentList() async {
        let coordinator = CoordinatorMock()
        let listId = FavoriteListID("list-1")
        let lists = [
            FavoriteList(id: listId, name: "Weekend", color: .mint, createdAt: Date())
        ]
        let viewModel = makeViewModel(
            listId: listId,
            lists: lists,
            coordinator: coordinator
        )

        viewModel.addMovieTapped()

        #expect(coordinator.presentedDestination == .favoriteListAddMovies(FavoriteListAddMoviesRequest(
            listId: listId,
            listName: "Weekend",
            initialQuery: "Spider-man"
        )))
        #expect(coordinator.presentedStyle == .sheet)
    }

    private func makeViewModel(
        listId: FavoriteListID,
        lists: [FavoriteList],
        coordinator: CoordinatorMock = CoordinatorMock()
    ) -> FavoriteListDetailsViewModel {
        FavoriteListDetailsViewModel(
            listId: listId,
            favoriteListsStateUseCase: { lists },
            favoriteListsSequenceUseCase: { AsyncStream { $0.finish() } },
            refreshFavoriteListsUseCase: {},
            refreshFavoritesUseCase: { _ in [] },
            coordinator: coordinator
        )
    }
}
