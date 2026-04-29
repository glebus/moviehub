import SwiftUI
import DomainModels
import DomainUseCases
import Coordinator

@MainActor
public struct FavoriteListDetailsBuilder {
    private let listId: FavoriteListID
    private let favoriteListsStateUseCase: FavoriteListsReader
    private let favoriteListsSequenceUseCase: FavoriteListsSequenceSource
    private let refreshFavoriteListsUseCase: RefreshFavoriteListsAction
    private let refreshFavoritesUseCase: RefreshFavoritesAction
    private let coordinator: any CoordinatorProtocol

    public init(
        listId: FavoriteListID,
        favoriteListsStateUseCase: @escaping FavoriteListsReader,
        favoriteListsSequenceUseCase: @escaping FavoriteListsSequenceSource,
        refreshFavoriteListsUseCase: @escaping RefreshFavoriteListsAction,
        refreshFavoritesUseCase: @escaping RefreshFavoritesAction,
        coordinator: any CoordinatorProtocol
    ) {
        self.listId = listId
        self.favoriteListsStateUseCase = favoriteListsStateUseCase
        self.favoriteListsSequenceUseCase = favoriteListsSequenceUseCase
        self.refreshFavoriteListsUseCase = refreshFavoriteListsUseCase
        self.refreshFavoritesUseCase = refreshFavoritesUseCase
        self.coordinator = coordinator
    }

    public func build() -> some View {
        let viewModel = FavoriteListDetailsViewModel(
            listId: listId,
            favoriteListsStateUseCase: favoriteListsStateUseCase,
            favoriteListsSequenceUseCase: favoriteListsSequenceUseCase,
            refreshFavoriteListsUseCase: refreshFavoriteListsUseCase,
            refreshFavoritesUseCase: refreshFavoritesUseCase,
            coordinator: coordinator
        )
        return FavoriteListDetailsScreen(viewModel: viewModel)
    }
}
