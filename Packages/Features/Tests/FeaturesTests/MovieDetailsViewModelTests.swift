import Testing
import DomainModels
import DomainUseCases
import DomainMocks
import Router
import AuthButton
@testable import MovieDetails

@MainActor
struct MovieDetailsViewModelTests {
    @Test
    func onAppearLoadsDetails() async {
        let router = AppRouterMock()
        let session = SessionUseCaseMock()
        let favoriteListsUseCases = FavoriteListsUseCaseMock()
        let favoritesUseCases = FavoritesUseCaseMock()
        let authButtonBuilder = AuthButtonBuilder(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            router: router
        )
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
            movieDetailsUseCase: { id in try await repo.details(id: id) },
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            favoriteListsStateUseCase: { favoriteListsUseCases.lists },
            favoriteListsSequenceUseCase: { favoriteListsUseCases.listsSequence },
            favoriteListByMovieStateUseCase: { favoritesUseCases.favoriteListByMovie },
            favoriteListByMovieSequenceUseCase: { favoritesUseCases.favoriteListByMovieSequence },
            removeFavoriteUseCase: { try await favoritesUseCases.removeFavorite(movieId: $0) },
            lookupFavoriteListUseCase: { try await favoritesUseCases.favoriteListId(movieId: $0) },
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
        let session = SessionUseCaseMock(currentUser: nil)
        let favoriteListsUseCases = FavoriteListsUseCaseMock()
        let favoritesUseCases = FavoritesUseCaseMock()
        let authButtonBuilder = AuthButtonBuilder(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            router: router
        )
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
            movieDetailsUseCase: { id in try await repo.details(id: id) },
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            favoriteListsStateUseCase: { favoriteListsUseCases.lists },
            favoriteListsSequenceUseCase: { favoriteListsUseCases.listsSequence },
            favoriteListByMovieStateUseCase: { favoritesUseCases.favoriteListByMovie },
            favoriteListByMovieSequenceUseCase: { favoritesUseCases.favoriteListByMovieSequence },
            removeFavoriteUseCase: { try await favoritesUseCases.removeFavorite(movieId: $0) },
            lookupFavoriteListUseCase: { try await favoritesUseCases.favoriteListId(movieId: $0) },
            router: router,
            authButtonBuilder: authButtonBuilder
        )

        await viewModel.loadDetails()
        await viewModel.toggleFavorite()

        #expect(router.lastSheetDestination == .auth)
    }
}
