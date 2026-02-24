import SwiftUI
import DomainModels
import DomainUseCases
import Router

@MainActor
public struct FavoriteListsManageBuilder {
    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let favoriteListsStateUseCase: FavoriteListsReader
    private let favoriteListsSequenceUseCase: FavoriteListsSequenceSource
    private let refreshFavoriteListsUseCase: RefreshFavoriteListsAction
    private let renameFavoriteListUseCase: RenameFavoriteListAction
    private let deleteFavoriteListUseCase: DeleteFavoriteListAction
    private let router: AppRouterProtocol

    public init(
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        favoriteListsStateUseCase: @escaping FavoriteListsReader,
        favoriteListsSequenceUseCase: @escaping FavoriteListsSequenceSource,
        refreshFavoriteListsUseCase: @escaping RefreshFavoriteListsAction,
        renameFavoriteListUseCase: @escaping RenameFavoriteListAction,
        deleteFavoriteListUseCase: @escaping DeleteFavoriteListAction,
        router: AppRouterProtocol
    ) {
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.favoriteListsStateUseCase = favoriteListsStateUseCase
        self.favoriteListsSequenceUseCase = favoriteListsSequenceUseCase
        self.refreshFavoriteListsUseCase = refreshFavoriteListsUseCase
        self.renameFavoriteListUseCase = renameFavoriteListUseCase
        self.deleteFavoriteListUseCase = deleteFavoriteListUseCase
        self.router = router
    }

    public func build() -> some View {
        let viewModel = FavoriteListsManageViewModel(
            currentUserUseCase: currentUserUseCase,
            currentUserSequenceUseCase: currentUserSequenceUseCase,
            favoriteListsStateUseCase: favoriteListsStateUseCase,
            favoriteListsSequenceUseCase: favoriteListsSequenceUseCase,
            refreshFavoriteListsUseCase: refreshFavoriteListsUseCase,
            renameFavoriteListUseCase: renameFavoriteListUseCase,
            deleteFavoriteListUseCase: deleteFavoriteListUseCase,
            router: router
        )
        return FavoriteListsManageScreen(viewModel: viewModel)
    }
}
