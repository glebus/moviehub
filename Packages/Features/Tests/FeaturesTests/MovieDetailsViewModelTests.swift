import Testing
import Domain
import DomainMocks
import Router
import AuthButton
@testable import MovieDetails

@MainActor
struct MovieDetailsViewModelTests {
    @Test
    func onAppearLoadsDetails() async {
        let router = AppRouterMock()
        let session = SessionInteractorMock()
        let favorites = FavoritesInteractorMock()
        let authButtonBuilder = AuthButtonBuilder(sessionInteractor: session, router: router)
        let repo = MovieRepositoryMock(
            detailsResult: MovieDetails(
                id: MovieID("10"),
                title: "Details",
                posterURL: nil,
                overview: "Overview",
                genres: ["Drama"],
                imdbURL: nil
            )
        )
        let viewModel = MovieDetailsViewModel(
            movieId: MovieID("10"),
            movieRepository: repo,
            sessionInteractor: session,
            favoritesInteractor: favorites,
            router: router,
            authButtonBuilder: authButtonBuilder
        )

        await viewModel.loadDetails()

        guard case .loaded(let model) = viewModel.state else {
            fail("Expected loaded state after onAppear")
            return
        }
        #expect(model.title == "Details")
    }

    @Test
    func favoriteWithoutAuthPresentsAuthSheet() async {
        let router = AppRouterMock()
        let session = SessionInteractorMock(currentUser: nil)
        let favorites = FavoritesInteractorMock()
        let authButtonBuilder = AuthButtonBuilder(sessionInteractor: session, router: router)
        let repo = MovieRepositoryMock(
            detailsResult: MovieDetails(
                id: MovieID("10"),
                title: "Details",
                posterURL: nil,
                overview: nil,
                genres: [],
                imdbURL: nil
            )
        )
        let viewModel = MovieDetailsViewModel(
            movieId: MovieID("10"),
            movieRepository: repo,
            sessionInteractor: session,
            favoritesInteractor: favorites,
            router: router,
            authButtonBuilder: authButtonBuilder
        )

        await viewModel.loadDetails()
        await viewModel.toggleFavorite()

        #expect(router.lastSheetDestination == .auth)
    }
}
