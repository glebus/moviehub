import SwiftUI
import Domain
import Router
import AuthButton

@MainActor
public struct FavoriteListDetailsBuilder {
    private let listId: FavoriteListID
    private let sessionInteractor: SessionInteractorProtocol
    private let favoriteListsInteractor: FavoriteListsInteractorProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let router: AppRouterProtocol
    private let authButtonBuilder: AuthButtonBuilder

    public init(
        listId: FavoriteListID,
        sessionInteractor: SessionInteractorProtocol,
        favoriteListsInteractor: FavoriteListsInteractorProtocol,
        favoritesRepository: FavoritesRepositoryProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.listId = listId
        self.sessionInteractor = sessionInteractor
        self.favoriteListsInteractor = favoriteListsInteractor
        self.favoritesRepository = favoritesRepository
        self.router = router
        self.authButtonBuilder = authButtonBuilder
    }

    public func build() -> FavoriteListDetailsScreen {
        let viewModel = FavoriteListDetailsViewModel(
            listId: listId,
            sessionInteractor: sessionInteractor,
            favoriteListsInteractor: favoriteListsInteractor,
            favoritesRepository: favoritesRepository,
            router: router,
            authButtonBuilder: authButtonBuilder
        )
        return FavoriteListDetailsScreen(viewModel: viewModel)
    }
}
