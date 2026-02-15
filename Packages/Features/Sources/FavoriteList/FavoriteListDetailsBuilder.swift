import SwiftUI
import Domain
import Router
import AuthButton

@MainActor
public struct FavoriteListDetailsBuilder {
    private let listId: FavoriteListID
    private let sessionInteractor: SessionInteractorProtocol
    private let favoriteListsInteractor: FavoriteListsInteractorProtocol
    private let favoritesInteractor: FavoritesInteractorProtocol
    private let router: AppRouterProtocol
    private let authButtonBuilder: AuthButtonBuilder

    public init(
        listId: FavoriteListID,
        sessionInteractor: SessionInteractorProtocol,
        favoriteListsInteractor: FavoriteListsInteractorProtocol,
        favoritesInteractor: FavoritesInteractorProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.listId = listId
        self.sessionInteractor = sessionInteractor
        self.favoriteListsInteractor = favoriteListsInteractor
        self.favoritesInteractor = favoritesInteractor
        self.router = router
        self.authButtonBuilder = authButtonBuilder
    }

    public func build() -> some View {
        let viewModel = FavoriteListDetailsViewModel(
            listId: listId,
            sessionInteractor: sessionInteractor,
            favoriteListsInteractor: favoriteListsInteractor,
            favoritesInteractor: favoritesInteractor,
            router: router,
            authButtonBuilder: authButtonBuilder
        )
        return FavoriteListDetailsScreen(viewModel: viewModel)
    }
}
