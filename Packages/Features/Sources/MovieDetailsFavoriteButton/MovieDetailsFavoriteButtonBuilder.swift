import SwiftUI
import DomainModels
import DomainUseCases
import Router
import DomainMocks

@MainActor
public struct MovieDetailsFavoriteButtonBuilder {
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let handleFavoriteTapUseCase: HandleMovieDetailsFavoriteTapAction
    private let lookupCurrentUserFavoriteListsUseCase: LookupCurrentUserFavoriteListsAction
    private let router: AppRouterProtocol

    public init(
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        handleFavoriteTapUseCase: @escaping HandleMovieDetailsFavoriteTapAction,
        lookupCurrentUserFavoriteListsUseCase: @escaping LookupCurrentUserFavoriteListsAction,
        router: AppRouterProtocol
    ) {
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.handleFavoriteTapUseCase = handleFavoriteTapUseCase
        self.lookupCurrentUserFavoriteListsUseCase = lookupCurrentUserFavoriteListsUseCase
        self.router = router
    }

    public func build(movieDetails: MovieDetails) -> some View {
        MovieDetailsFavoriteButton(viewModel: makeViewModel(movieDetails: movieDetails))
    }

    func makeViewModel(movieDetails: MovieDetails) -> MovieDetailsFavoriteButtonViewModel {
        let viewModel = MovieDetailsFavoriteButtonViewModel(
            movieDetails: movieDetails,
            currentUserSequenceUseCase: currentUserSequenceUseCase,
            handleFavoriteTapUseCase: handleFavoriteTapUseCase,
            lookupCurrentUserFavoriteListsUseCase: lookupCurrentUserFavoriteListsUseCase,
            router: router
        )
        return viewModel
    }

    public static func preview(movieId: MovieID = MovieID("m1")) -> MovieDetailsFavoriteButtonBuilder {
        let router = AppRouterMock()
        let session = SessionUseCaseMock(currentUser: User(id: UserID("user"), username: "user"))
        let favoriteListsUseCases = FavoriteListsUseCaseMock(lists: [
            FavoriteList(id: FavoriteListID("l1"), name: "Comedies", color: .mint, createdAt: Date())
        ])
        let favoritesUseCases = FavoritesUseCaseMock()

        return MovieDetailsFavoriteButtonBuilder(
            currentUserSequenceUseCase: { session.currentUserSequence },
            handleFavoriteTapUseCase: { details in
                if session.currentUser == nil {
                    return .requireAuth
                }
                if !(try await favoritesUseCases.favoriteListIds(movieId: details.id)).isEmpty {
                    try await favoritesUseCases.removeFavorite(movieId: details.id)
                    return .removed
                }
                if favoriteListsUseCases.lists.isEmpty {
                    return .showCreateList
                }
                return .showPicker(details)
            },
            lookupCurrentUserFavoriteListsUseCase: { movieId in
                guard session.currentUser != nil else {
                    return .requireAuth
                }
                return .favoriteListIDs(try await favoritesUseCases.favoriteListIds(movieId: movieId))
            },
            router: router
        )
    }
}
