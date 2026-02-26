import SwiftUI
import DomainUseCases
import Router

@MainActor
public struct FavoriteListAddMoviesBuilder {
    private let request: FavoriteListAddMoviesRequest
    private let searchMoviesUseCase: SearchMoviesAction
    private let movieDetailsUseCase: MovieDetailsAction
    private let favoritesByListStateUseCase: FavoritesByListReader
    private let favoritesByListSequenceUseCase: FavoritesByListSequenceSource
    private let refreshFavoritesUseCase: RefreshFavoritesAction
    private let addFavoriteUseCase: AddFavoriteAction
    private let removeFavoriteFromListUseCase: RemoveFavoriteFromListAction
    private let router: AppRouterProtocol

    public init(
        request: FavoriteListAddMoviesRequest,
        searchMoviesUseCase: @escaping SearchMoviesAction,
        movieDetailsUseCase: @escaping MovieDetailsAction,
        favoritesByListStateUseCase: @escaping FavoritesByListReader,
        favoritesByListSequenceUseCase: @escaping FavoritesByListSequenceSource,
        refreshFavoritesUseCase: @escaping RefreshFavoritesAction,
        addFavoriteUseCase: @escaping AddFavoriteAction,
        removeFavoriteFromListUseCase: @escaping RemoveFavoriteFromListAction,
        router: AppRouterProtocol
    ) {
        self.request = request
        self.searchMoviesUseCase = searchMoviesUseCase
        self.movieDetailsUseCase = movieDetailsUseCase
        self.favoritesByListStateUseCase = favoritesByListStateUseCase
        self.favoritesByListSequenceUseCase = favoritesByListSequenceUseCase
        self.refreshFavoritesUseCase = refreshFavoritesUseCase
        self.addFavoriteUseCase = addFavoriteUseCase
        self.removeFavoriteFromListUseCase = removeFavoriteFromListUseCase
        self.router = router
    }

    public func build() -> some View {
        FavoriteListAddMoviesScreen(
            viewModel: FavoriteListAddMoviesViewModel(
                request: request,
                searchMoviesUseCase: searchMoviesUseCase,
                movieDetailsUseCase: movieDetailsUseCase,
                favoritesByListStateUseCase: favoritesByListStateUseCase,
                favoritesByListSequenceUseCase: favoritesByListSequenceUseCase,
                refreshFavoritesUseCase: refreshFavoritesUseCase,
                addFavoriteUseCase: addFavoriteUseCase,
                removeFavoriteFromListUseCase: removeFavoriteFromListUseCase,
                router: router
            )
        )
    }
}
