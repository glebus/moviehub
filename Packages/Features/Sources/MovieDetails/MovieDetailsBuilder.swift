import SwiftUI
import Domain
import Router
import AuthButton
import DomainMocks

@MainActor
public struct MovieDetailsBuilder {
    private let movieRepository: MovieRepositoryProtocol
    private let sessionInteractor: SessionInteractorProtocol
    private let favoriteListsInteractor: FavoriteListsInteractorProtocol
    private let favoritesInteractor: FavoritesInteractorProtocol
    private let router: AppRouterProtocol
    private let authButtonBuilder: AuthButtonBuilder

    public init(
        movieRepository: MovieRepositoryProtocol,
        sessionInteractor: SessionInteractorProtocol,
        favoriteListsInteractor: FavoriteListsInteractorProtocol,
        favoritesInteractor: FavoritesInteractorProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.movieRepository = movieRepository
        self.sessionInteractor = sessionInteractor
        self.favoriteListsInteractor = favoriteListsInteractor
        self.favoritesInteractor = favoritesInteractor
        self.router = router
        self.authButtonBuilder = authButtonBuilder
    }

    public func build(movieId: MovieID) -> MovieDetailsScreen {
        let viewModel = MovieDetailsViewModel(
            movieId: movieId,
            movieRepository: movieRepository,
            sessionInteractor: sessionInteractor,
            favoriteListsInteractor: favoriteListsInteractor,
            favoritesInteractor: favoritesInteractor,
            router: router,
            authButtonBuilder: authButtonBuilder
        )
        return MovieDetailsScreen(viewModel: viewModel)
    }

    public static func preview(movieId: MovieID = MovieID("m1")) -> MovieDetailsBuilder {
        let router = AppRouterMock()
        let session = SessionInteractorMock(currentUser: User(id: UserID("user"), username: "user"))
        let listsRepository = FavoriteListsRepositoryMock()
        let favoritesRepository = FavoritesRepositoryMock()
        let favoriteListsInteractor = FavoriteListsInteractor(
            listsRepository: listsRepository,
            sessionInteractor: session
        )
        let favoritesInteractor = FavoritesInteractor(
            favoritesRepository: favoritesRepository,
            sessionInteractor: session
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
        Task {
            await listsRepository.seedLists([
                FavoriteList(id: FavoriteListID("l1"), name: "Comedies", color: .mint, createdAt: Date())
            ], for: UserID("user"))
            try? await favoriteListsInteractor.refresh()
        }

        return MovieDetailsBuilder(
            movieRepository: movieRepo,
            sessionInteractor: session,
            favoriteListsInteractor: favoriteListsInteractor,
            favoritesInteractor: favoritesInteractor,
            router: router,
            authButtonBuilder: AuthButtonBuilder.preview()
        )
    }
}
