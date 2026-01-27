import SwiftUI
import Domain
import Router
import AuthButton
import DomainMocks

@MainActor
public struct MovieDetailsBuilder {
    private let movieRepository: MovieRepositoryProtocol
    private let sessionInteractor: SessionInteractorProtocol
    private let favoritesInteractor: FavoritesInteractorProtocol
    private let router: AppRouterProtocol
    private let authButtonBuilder: AuthButtonBuilder

    public init(
        movieRepository: MovieRepositoryProtocol,
        sessionInteractor: SessionInteractorProtocol,
        favoritesInteractor: FavoritesInteractorProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.movieRepository = movieRepository
        self.sessionInteractor = sessionInteractor
        self.favoritesInteractor = favoritesInteractor
        self.router = router
        self.authButtonBuilder = authButtonBuilder
    }

    public func build(movieId: MovieID) -> MovieDetailsScreen {
        let viewModel = MovieDetailsViewModel(
            movieId: movieId,
            movieRepository: movieRepository,
            sessionInteractor: sessionInteractor,
            favoritesInteractor: favoritesInteractor,
            router: router,
            authButtonBuilder: authButtonBuilder
        )
        return MovieDetailsScreen(viewModel: viewModel)
    }

    public static func preview(movieId: MovieID = MovieID("m1")) -> MovieDetailsBuilder {
        let router = AppRouterMock()
        let session = SessionInteractorMock()
        let favorites = FavoritesInteractorMock(
            favorites: [
                Movie(id: movieId, title: "Preview Favorite", year: "2020", posterURL: nil)
            ]
        )
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
            movieRepository: movieRepo,
            sessionInteractor: session,
            favoritesInteractor: favorites,
            router: router,
            authButtonBuilder: AuthButtonBuilder.preview()
        )
    }
}
