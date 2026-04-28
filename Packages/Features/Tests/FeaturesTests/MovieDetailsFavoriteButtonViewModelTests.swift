import Testing
import DomainModels
import DomainMocks
import Coordinator
@testable import MovieDetailsFavoriteButton

@MainActor
struct MovieDetailsFavoriteButtonViewModelTests {
    @Test
    func favoriteWithoutAuthPresentsAuthSheet() async {
        let coordinator = CoordinatorMock()
        let session = SessionUseCaseMock(currentUser: nil)
        let favoriteListsUseCases = FavoriteListsUseCaseMock()
        let favoritesUseCases = FavoritesUseCaseMock()
        let builder = MovieDetailsFavoriteButtonBuilder(
            currentUserSequenceUseCase: { session.currentUserSequence },
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
            lookupCurrentUserFavoriteListsUseCase: { movieId in
                guard session.currentUser != nil else {
                    return .requireAuth
                }
                return .favoriteListIDs(try await favoritesUseCases.favoriteListIds(movieId: movieId))
            },
            coordinator: coordinator
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

        #expect(coordinator.presentedDestination == .auth)
    }
}
