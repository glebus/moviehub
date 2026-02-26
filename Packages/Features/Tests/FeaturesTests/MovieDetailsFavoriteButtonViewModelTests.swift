import Testing
import DomainModels
import DomainMocks
import Router
@testable import MovieDetailsFavoriteButton

@MainActor
struct MovieDetailsFavoriteButtonViewModelTests {
    @Test
    func favoriteWithoutAuthPresentsAuthSheet() async {
        let router = AppRouterMock()
        let session = SessionUseCaseMock(currentUser: nil)
        let favoriteListsUseCases = FavoriteListsUseCaseMock()
        let favoritesUseCases = FavoritesUseCaseMock()
        let builder = MovieDetailsFavoriteButtonBuilder(
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
        let viewModel = builder.makeViewModel(movieDetails:
            MovieDetails(
                id: MovieID("10"),
                title: "Details",
                posterURL: nil,
                overview: nil,
                genres: [],
                imdbURL: nil
            )
        )

        await viewModel.toggleFavorite()

        #expect(router.lastSheetDestination == .auth)
    }
}
