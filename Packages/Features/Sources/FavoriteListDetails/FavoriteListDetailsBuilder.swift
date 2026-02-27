import SwiftUI
import DomainModels
import DomainUseCases
import Router
import AuthButton

@MainActor
public struct FavoriteListDetailsBuilder {
    private let listId: FavoriteListID
    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let favoriteListsStateUseCase: FavoriteListsReader
    private let favoriteListsSequenceUseCase: FavoriteListsSequenceSource
    private let refreshFavoriteListsUseCase: RefreshFavoriteListsAction
    private let refreshFavoritesUseCase: RefreshFavoritesAction
    private let router: AppRouterProtocol
    private let authButtonBuilder: AuthButtonBuilder

    public init(
        listId: FavoriteListID,
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        favoriteListsStateUseCase: @escaping FavoriteListsReader,
        favoriteListsSequenceUseCase: @escaping FavoriteListsSequenceSource,
        refreshFavoriteListsUseCase: @escaping RefreshFavoriteListsAction,
        refreshFavoritesUseCase: @escaping RefreshFavoritesAction,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.listId = listId
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.favoriteListsStateUseCase = favoriteListsStateUseCase
        self.favoriteListsSequenceUseCase = favoriteListsSequenceUseCase
        self.refreshFavoriteListsUseCase = refreshFavoriteListsUseCase
        self.refreshFavoritesUseCase = refreshFavoritesUseCase
        self.router = router
        self.authButtonBuilder = authButtonBuilder
    }

    public func build() -> some View {
        let viewModel = FavoriteListDetailsViewModel(
            listId: listId,
            currentUserUseCase: currentUserUseCase,
            currentUserSequenceUseCase: currentUserSequenceUseCase,
            favoriteListsStateUseCase: favoriteListsStateUseCase,
            favoriteListsSequenceUseCase: favoriteListsSequenceUseCase,
            refreshFavoriteListsUseCase: refreshFavoriteListsUseCase,
            refreshFavoritesUseCase: refreshFavoritesUseCase,
            router: router,
            authButtonBuilder: authButtonBuilder
        )
        return FavoriteListDetailsScreen(viewModel: viewModel)
    }
}
