import SwiftUI
import Domain
import Router
import AuthButton

@MainActor
public struct FavoriteListPickerBuilder {
    private let movieDetails: MovieDetails
    private let sessionInteractor: SessionInteractorProtocol
    private let favoriteListsInteractor: FavoriteListsInteractorProtocol
    private let favoritesInteractor: FavoritesInteractorProtocol
    private let router: AppRouterProtocol
    private let authButtonBuilder: AuthButtonBuilder

    public init(
        movieDetails: MovieDetails,
        sessionInteractor: SessionInteractorProtocol,
        favoriteListsInteractor: FavoriteListsInteractorProtocol,
        favoritesInteractor: FavoritesInteractorProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.movieDetails = movieDetails
        self.sessionInteractor = sessionInteractor
        self.favoriteListsInteractor = favoriteListsInteractor
        self.favoritesInteractor = favoritesInteractor
        self.router = router
        self.authButtonBuilder = authButtonBuilder
    }

    public func build() -> some View {
        let viewModel = FavoriteListPickerViewModel(
            movieDetails: movieDetails,
            sessionInteractor: sessionInteractor,
            favoriteListsInteractor: favoriteListsInteractor,
            favoritesInteractor: favoritesInteractor,
            router: router,
            authButtonBuilder: authButtonBuilder
        )
        return FavoriteListPickerScreen(viewModel: viewModel)
    }
}
