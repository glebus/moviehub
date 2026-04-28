import SwiftUI
import DomainUseCases
import Coordinator

@MainActor
public struct FavoriteListAddMoviesBuilder {
    private let request: FavoriteListAddMoviesRequest
    private let searchMoviesUseCase: SearchMoviesAction
    private let movieDetailsUseCase: MovieDetailsAction
    private let refreshFavoritesUseCase: RefreshFavoritesAction
    private let addFavoriteUseCase: AddFavoriteAction
    private let removeFavoriteFromListUseCase: RemoveFavoriteFromListAction
    private let coordinator: any CoordinatorProtocol

    public init(
        request: FavoriteListAddMoviesRequest,
        searchMoviesUseCase: @escaping SearchMoviesAction,
        movieDetailsUseCase: @escaping MovieDetailsAction,
        refreshFavoritesUseCase: @escaping RefreshFavoritesAction,
        addFavoriteUseCase: @escaping AddFavoriteAction,
        removeFavoriteFromListUseCase: @escaping RemoveFavoriteFromListAction,
        coordinator: any CoordinatorProtocol
    ) {
        self.request = request
        self.searchMoviesUseCase = searchMoviesUseCase
        self.movieDetailsUseCase = movieDetailsUseCase
        self.refreshFavoritesUseCase = refreshFavoritesUseCase
        self.addFavoriteUseCase = addFavoriteUseCase
        self.removeFavoriteFromListUseCase = removeFavoriteFromListUseCase
        self.coordinator = coordinator
    }

    public func build() -> some View {
        FavoriteListAddMoviesScreen(
            viewModel: FavoriteListAddMoviesViewModel(
                request: request,
                searchMoviesUseCase: searchMoviesUseCase,
                movieDetailsUseCase: movieDetailsUseCase,
                refreshFavoritesUseCase: refreshFavoritesUseCase,
                addFavoriteUseCase: addFavoriteUseCase,
                removeFavoriteFromListUseCase: removeFavoriteFromListUseCase,
                coordinator: coordinator
            )
        )
    }
}
