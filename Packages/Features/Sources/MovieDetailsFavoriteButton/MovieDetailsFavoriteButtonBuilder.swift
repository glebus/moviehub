import SwiftUI
import DomainModels
import DomainUseCases
import Router
import DomainMocks

@MainActor
public struct MovieDetailsFavoriteButtonBuilder {
    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let favoriteListsByMovieStateUseCase: FavoriteListsByMovieReader
    private let favoriteListsByMovieSequenceUseCase: FavoriteListsByMovieSequenceSource
    private let handleFavoriteTapUseCase: HandleMovieDetailsFavoriteTapAction
    private let lookupFavoriteListsUseCase: LookupFavoriteListsAction
    private let router: AppRouterProtocol

    public init(
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        favoriteListsByMovieStateUseCase: @escaping FavoriteListsByMovieReader,
        favoriteListsByMovieSequenceUseCase: @escaping FavoriteListsByMovieSequenceSource,
        handleFavoriteTapUseCase: @escaping HandleMovieDetailsFavoriteTapAction,
        lookupFavoriteListsUseCase: @escaping LookupFavoriteListsAction,
        router: AppRouterProtocol
    ) {
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.favoriteListsByMovieStateUseCase = favoriteListsByMovieStateUseCase
        self.favoriteListsByMovieSequenceUseCase = favoriteListsByMovieSequenceUseCase
        self.handleFavoriteTapUseCase = handleFavoriteTapUseCase
        self.lookupFavoriteListsUseCase = lookupFavoriteListsUseCase
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
            favoriteListsByMovieStateUseCase: favoriteListsByMovieStateUseCase,
            favoriteListsByMovieSequenceUseCase: favoriteListsByMovieSequenceUseCase,
            handleFavoriteTapUseCase: handleFavoriteTapUseCase,
            lookupFavoriteListsUseCase: lookupFavoriteListsUseCase,
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
            favoriteListsByMovieStateUseCase: { favoritesUseCases.favoriteListsByMovie },
            favoriteListsByMovieSequenceUseCase: { favoritesUseCases.favoriteListsByMovieSequence },
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
            lookupFavoriteListsUseCase: { try await favoritesUseCases.favoriteListIds(movieId: $0) },
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
