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

        let states = await recordChanges(count: 2, observe: { viewModel.state }) {
            viewModel.onAppear()
        }

        guard case .loaded(let model) = viewModel.state else {
            fail("Expected loaded state after onAppear")
            return
        }
        #expect(model.title == "Details")
        #expect(states.contains { if case .loading = $0 { true } else { false } })
        #expect(states.contains { if case .loaded = $0 { true } else { false } })
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

        _ = await recordChanges(count: 2, observe: { viewModel.state }) {
            viewModel.onAppear()
        }

        let sheetValues = await recordChanges(count: 1, observe: { router.lastSheetDestination }) {
            viewModel.favoriteButtonTapped()
        }

        #expect(sheetValues.last == .auth)
    }
}
