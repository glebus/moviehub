import SwiftUI
import Domain
import Router
import AuthButton

@MainActor
public struct FavoriteListPickerBuilder {
    private let movieDetails: MovieDetails
    private let sessionInteractor: SessionInteractorProtocol
    private let favoriteListsInteractor: FavoriteListsInteractorProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let router: AppRouterProtocol
    private let authButtonBuilder: AuthButtonBuilder

    public init(
        movieDetails: MovieDetails,
        sessionInteractor: SessionInteractorProtocol,
        favoriteListsInteractor: FavoriteListsInteractorProtocol,
        favoritesRepository: FavoritesRepositoryProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.movieDetails = movieDetails
        self.sessionInteractor = sessionInteractor
        self.favoriteListsInteractor = favoriteListsInteractor
        self.favoritesRepository = favoritesRepository
        self.router = router
        self.authButtonBuilder = authButtonBuilder
    }

    public func build() -> FavoriteListPickerScreen {
        let viewModel = FavoriteListPickerViewModel(
            movieDetails: movieDetails,
            sessionInteractor: sessionInteractor,
            favoriteListsInteractor: favoriteListsInteractor,
            favoritesRepository: favoritesRepository,
            router: router,
            authButtonBuilder: authButtonBuilder
        )
        return FavoriteListPickerScreen(viewModel: viewModel)
    }
}
