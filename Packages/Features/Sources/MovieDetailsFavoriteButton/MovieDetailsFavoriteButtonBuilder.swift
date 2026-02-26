import SwiftUI
import DomainModels
import DomainUseCases
import Router
import DomainMocks

@MainActor
public struct MovieDetailsFavoriteButtonBuilder {
    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let favoriteListByMovieStateUseCase: FavoriteListByMovieReader
    private let favoriteListByMovieSequenceUseCase: FavoriteListByMovieSequenceSource
    private let handleFavoriteTapUseCase: HandleMovieDetailsFavoriteTapAction
    private let lookupFavoriteListUseCase: LookupFavoriteListAction
    private let router: AppRouterProtocol

    public init(
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        favoriteListByMovieStateUseCase: @escaping FavoriteListByMovieReader,
        favoriteListByMovieSequenceUseCase: @escaping FavoriteListByMovieSequenceSource,
        handleFavoriteTapUseCase: @escaping HandleMovieDetailsFavoriteTapAction,
        lookupFavoriteListUseCase: @escaping LookupFavoriteListAction,
        router: AppRouterProtocol
    ) {
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.favoriteListByMovieStateUseCase = favoriteListByMovieStateUseCase
        self.favoriteListByMovieSequenceUseCase = favoriteListByMovieSequenceUseCase
        self.handleFavoriteTapUseCase = handleFavoriteTapUseCase
        self.lookupFavoriteListUseCase = lookupFavoriteListUseCase
        self.router = router
    }

    public func build(movieDetails: MovieDetails) -> some View {
        MovieDetailsFavoriteButton(viewModel: makeViewModel(movieDetails: movieDetails))
    }

    func makeViewModel(movieDetails: MovieDetails) -> MovieDetailsFavoriteButtonViewModel {
        MovieDetailsFavoriteButtonViewModel(
            movieDetails: movieDetails,
            currentUserUseCase: currentUserUseCase,
            currentUserSequenceUseCase: currentUserSequenceUseCase,
            favoriteListByMovieStateUseCase: favoriteListByMovieStateUseCase,
            favoriteListByMovieSequenceUseCase: favoriteListByMovieSequenceUseCase,
            handleFavoriteTapUseCase: handleFavoriteTapUseCase,
            lookupFavoriteListUseCase: lookupFavoriteListUseCase,
            router: router
        )
    }

    public static func preview(movieId: MovieID = MovieID("m1")) -> MovieDetailsFavoriteButtonBuilder {
        let router = AppRouterMock()
        let session = SessionUseCaseMock(currentUser: User(id: UserID("user"), username: "user"))
        let favoriteListsUseCases = FavoriteListsUseCaseMock(lists: [
            FavoriteList(id: FavoriteListID("l1"), name: "Comedies", color: .mint, createdAt: Date())
        ])
        let favoritesUseCases = FavoritesUseCaseMock()

        return MovieDetailsFavoriteButtonBuilder(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            favoriteListByMovieStateUseCase: { favoritesUseCases.favoriteListByMovie },
            favoriteListByMovieSequenceUseCase: { favoritesUseCases.favoriteListByMovieSequence },
            handleFavoriteTapUseCase: { details in
                if session.currentUser == nil {
                    return .requireAuth
                }
                if try await favoritesUseCases.favoriteListId(movieId: details.id) != nil {
                    try await favoritesUseCases.removeFavorite(movieId: details.id)
                    return .removed
                }
                if favoriteListsUseCases.lists.isEmpty {
                    return .showCreateList
                }
                return .showPicker(details)
            },
            lookupFavoriteListUseCase: { try await favoritesUseCases.favoriteListId(movieId: $0) },
            router: router
        )
    }
}

#Preview {
    let details = MovieDetails(
        id: MovieID("m1"),
        title: "Preview Movie",
        posterURL: nil,
        overview: "A preview overview for the movie details screen.",
        genres: ["Drama", "Action"],
        imdbURL: nil
    )
    let builder = MovieDetailsFavoriteButtonBuilder.preview(movieId: details.id)
    return builder.build(movieDetails: details)
}
