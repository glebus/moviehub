import SwiftUI
import DomainModels
import DomainUseCases
import Router
import AuthButton
import DomainMocks

@MainActor
public struct MovieDetailsBuilder {
    private let movieDetailsUseCase: MovieDetailsAction
    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let favoriteListsStateUseCase: FavoriteListsReader
    private let favoriteListsSequenceUseCase: FavoriteListsSequenceSource
    private let favoriteListByMovieStateUseCase: FavoriteListByMovieReader
    private let favoriteListByMovieSequenceUseCase: FavoriteListByMovieSequenceSource
    private let removeFavoriteUseCase: RemoveFavoriteAction
    private let lookupFavoriteListUseCase: LookupFavoriteListAction
    private let router: AppRouterProtocol
    private let authButtonBuilder: AuthButtonBuilder

    public init(
        movieDetailsUseCase: @escaping MovieDetailsAction,
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        favoriteListsStateUseCase: @escaping FavoriteListsReader,
        favoriteListsSequenceUseCase: @escaping FavoriteListsSequenceSource,
        favoriteListByMovieStateUseCase: @escaping FavoriteListByMovieReader,
        favoriteListByMovieSequenceUseCase: @escaping FavoriteListByMovieSequenceSource,
        removeFavoriteUseCase: @escaping RemoveFavoriteAction,
        lookupFavoriteListUseCase: @escaping LookupFavoriteListAction,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.movieDetailsUseCase = movieDetailsUseCase
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.favoriteListsStateUseCase = favoriteListsStateUseCase
        self.favoriteListsSequenceUseCase = favoriteListsSequenceUseCase
        self.favoriteListByMovieStateUseCase = favoriteListByMovieStateUseCase
        self.favoriteListByMovieSequenceUseCase = favoriteListByMovieSequenceUseCase
        self.removeFavoriteUseCase = removeFavoriteUseCase
        self.lookupFavoriteListUseCase = lookupFavoriteListUseCase
        self.router = router
        self.authButtonBuilder = authButtonBuilder
    }

    public func build(movieId: MovieID) -> MovieDetailsScreen {
        let viewModel = MovieDetailsViewModel(
            movieId: movieId,
            movieDetailsUseCase: movieDetailsUseCase,
            currentUserUseCase: currentUserUseCase,
            currentUserSequenceUseCase: currentUserSequenceUseCase,
            favoriteListsStateUseCase: favoriteListsStateUseCase,
            favoriteListsSequenceUseCase: favoriteListsSequenceUseCase,
            favoriteListByMovieStateUseCase: favoriteListByMovieStateUseCase,
            favoriteListByMovieSequenceUseCase: favoriteListByMovieSequenceUseCase,
            removeFavoriteUseCase: removeFavoriteUseCase,
            lookupFavoriteListUseCase: lookupFavoriteListUseCase,
            router: router,
            authButtonBuilder: authButtonBuilder
        )
        return MovieDetailsScreen(viewModel: viewModel)
    }

    public static func preview(movieId: MovieID = MovieID("m1")) -> MovieDetailsBuilder {
        let router = AppRouterMock()
        let session = SessionUseCaseMock(currentUser: User(id: UserID("user"), username: "user"))
        let favoriteListsUseCases = FavoriteListsUseCaseMock(lists: [
            FavoriteList(id: FavoriteListID("l1"), name: "Comedies", color: .mint, createdAt: Date())
        ])
        let favoritesUseCases = FavoritesUseCaseMock()
        let movieRepo = MovieRepositoryMock(
            detailsResult: MovieDetails(
                id: movieId,
                title: "Preview Movie",
                posterURL: nil,
                overview: "A preview overview for the movie details screen.",
                genres: ["Drama", "Action"],
                imdbURL: nil
            )
        )

        return MovieDetailsBuilder(
            movieDetailsUseCase: { id in try await movieRepo.details(id: id) },
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            favoriteListsStateUseCase: { favoriteListsUseCases.lists },
            favoriteListsSequenceUseCase: { favoriteListsUseCases.listsSequence },
            favoriteListByMovieStateUseCase: { favoritesUseCases.favoriteListByMovie },
            favoriteListByMovieSequenceUseCase: { favoritesUseCases.favoriteListByMovieSequence },
            removeFavoriteUseCase: { try await favoritesUseCases.removeFavorite(movieId: $0) },
            lookupFavoriteListUseCase: { try await favoritesUseCases.favoriteListId(movieId: $0) },
            router: router,
            authButtonBuilder: AuthButtonBuilder.preview()
        )
    }
}
