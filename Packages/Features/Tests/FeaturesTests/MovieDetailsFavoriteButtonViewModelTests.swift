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
