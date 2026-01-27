import SwiftUI
import Domain
import Router
import DomainMocks

@MainActor
public struct FavoriteListBuilder {
    private let sessionInteractor: SessionInteractorProtocol
    private let favoritesInteractor: FavoritesInteractorProtocol
    private let router: AppRouterProtocol

    public init(
        sessionInteractor: SessionInteractorProtocol,
        favoritesInteractor: FavoritesInteractorProtocol,
        router: AppRouterProtocol
    ) {
        self.sessionInteractor = sessionInteractor
        self.favoritesInteractor = favoritesInteractor
        self.router = router
    }

    public func build() -> FavoriteListScreen {
        let viewModel = FavoriteListViewModel(
            sessionInteractor: sessionInteractor,
            favoritesInteractor: favoritesInteractor,
            router: router
        )
        return FavoriteListScreen(viewModel: viewModel)
    }

    public static func preview() -> FavoriteListBuilder {
        let router = AppRouterMock()
        let session = SessionInteractorMock()
        let favorites = FavoritesInteractorMock(
            favorites: [
                Movie(id: MovieID("m1"), title: "Preview Favorite", year: "2020", posterURL: nil),
                Movie(id: MovieID("m2"), title: "Another Favorite", year: "2019", posterURL: nil)
            ]
        )

        return FavoriteListBuilder(
            sessionInteractor: session,
            favoritesInteractor: favorites,
            router: router
        )
    }
}
