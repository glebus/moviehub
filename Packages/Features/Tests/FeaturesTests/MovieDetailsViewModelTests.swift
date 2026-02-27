import Testing
import DomainModels
import DomainUseCases
import DomainMocks
import Router
import AuthButton
import MovieDetailsFavoriteButton
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
        let favoriteButtonBuilder = MovieDetailsFavoriteButtonBuilder(
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
            authButtonBuilder: authButtonBuilder,
            favoriteButtonBuilder: favoriteButtonBuilder
        )

        await viewModel.loadDetails()

        guard case .loaded(let model) = viewModel.state else {
            fail("Expected loaded state after onAppear")
            return
        }
        #expect(model.title == "Details")
    }
}
