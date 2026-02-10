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
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let router: AppRouterProtocol
    private let authButtonBuilder: AuthButtonBuilder

    public init(
        movieRepository: MovieRepositoryProtocol,
        sessionInteractor: SessionInteractorProtocol,
        favoriteListsInteractor: FavoriteListsInteractorProtocol,
        favoritesRepository: FavoritesRepositoryProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.movieRepository = movieRepository
        self.sessionInteractor = sessionInteractor
        self.favoriteListsInteractor = favoriteListsInteractor
        self.favoritesRepository = favoritesRepository
        self.router = router
        self.authButtonBuilder = authButtonBuilder
    }

    public func build(movieId: MovieID) -> MovieDetailsScreen {
        let viewModel = MovieDetailsViewModel(
            movieId: movieId,
            movieRepository: movieRepository,
            sessionInteractor: sessionInteractor,
            favoriteListsInteractor: favoriteListsInteractor,
            favoritesRepository: favoritesRepository,
            router: router,
            authButtonBuilder: authButtonBuilder
        )
        return MovieDetailsScreen(viewModel: viewModel)
    }

    public static func preview(movieId: MovieID = MovieID("m1")) -> MovieDetailsBuilder {
        let router = AppRouterMock()
        let session = SessionInteractorMock(currentUser: User(id: UserID("user"), username: "user"))
        let listsRepository = FavoriteListsRepositoryMock()
        let listsInteractor = FavoriteListsInteractor(
            listsRepository: listsRepository,
            sessionInteractor: session
        )
        let favoritesRepository = FavoritesRepositoryMock()
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
            try? await listsInteractor.refresh()
        }

        return MovieDetailsBuilder(
            movieRepository: movieRepo,
            sessionInteractor: session,
            favoriteListsInteractor: listsInteractor,
            favoritesRepository: favoritesRepository,
            router: router,
            authButtonBuilder: AuthButtonBuilder.preview()
        )
    }
}
