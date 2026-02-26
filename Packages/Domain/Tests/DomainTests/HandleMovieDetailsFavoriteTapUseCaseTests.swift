import Foundation
import Testing
@testable import DomainModels
import DomainUseCases
import DomainMocks

@MainActor
struct HandleMovieDetailsFavoriteTapUseCaseTests {
    @Test
    func returnsRequireAuthWhenNoSession() async throws {
        let profileRepo = ProfileRepositoryMock()
        let listsRepo = FavoriteListsRepositoryMock()
        let favoritesRepo = FavoritesRepositoryMock()
        let useCase = HandleMovieDetailsFavoriteTapUseCase(
            profileRepository: profileRepo,
            favoriteListsRepository: listsRepo,
            favoritesRepository: favoritesRepo
        )

        let result = try await useCase.handleTap(movieDetails: sampleMovieDetails())

        guard case .requireAuth = result else {
            fail("Expected requireAuth")
            return
        }
    }

    @Test
    func returnsShowCreateListWhenNoListsAndMovieNotFavorite() async throws {
        let profileRepo = ProfileRepositoryMock()
        let listsRepo = FavoriteListsRepositoryMock()
        let favoritesRepo = FavoritesRepositoryMock()
        let user = User(id: UserID("u1"), username: "alex")
        profileRepo.setCurrentUser(user)
        let useCase = HandleMovieDetailsFavoriteTapUseCase(
            profileRepository: profileRepo,
            favoriteListsRepository: listsRepo,
            favoritesRepository: favoritesRepo
        )

        let result = try await useCase.handleTap(movieDetails: sampleMovieDetails())

        guard case .showCreateList = result else {
            fail("Expected showCreateList")
            return
        }
    }

    @Test
    func returnsRemovedAndDeletesExistingFavorite() async throws {
        let profileRepo = ProfileRepositoryMock()
        let listsRepo = FavoriteListsRepositoryMock()
        let favoritesRepo = FavoritesRepositoryMock()
        let user = User(id: UserID("u1"), username: "alex")
        let listId = FavoriteListID("l1")
        profileRepo.setCurrentUser(user)
        listsRepo.seedLists([
            FavoriteList(id: listId, name: "Comedies", color: .mint, createdAt: Date())
        ], for: user.id)
        favoritesRepo.seedFavorites([
            Movie(id: MovieID("m1"), title: "Movie", year: nil, posterURL: nil)
        ], for: user.id, listId: listId)

        let useCase = HandleMovieDetailsFavoriteTapUseCase(
            profileRepository: profileRepo,
            favoriteListsRepository: listsRepo,
            favoritesRepository: favoritesRepo
        )

        let result = try await useCase.handleTap(movieDetails: sampleMovieDetails())

        guard case .removed = result else {
            fail("Expected removed")
            return
        }
        let lookup = try await favoritesRepo.favoriteListId(userId: user.id, movieId: MovieID("m1"))
        #expect(lookup == nil)
    }

    @Test
    func returnsShowPickerWhenListsExistAndMovieNotFavorite() async throws {
        let profileRepo = ProfileRepositoryMock()
        let listsRepo = FavoriteListsRepositoryMock()
        let favoritesRepo = FavoritesRepositoryMock()
        let user = User(id: UserID("u1"), username: "alex")
        profileRepo.setCurrentUser(user)
        listsRepo.seedLists([
            FavoriteList(id: FavoriteListID("l1"), name: "Comedies", color: .mint, createdAt: Date())
        ], for: user.id)
        _ = try await listsRepo.fetchLists(userId: user.id)

        let details = sampleMovieDetails()
        let useCase = HandleMovieDetailsFavoriteTapUseCase(
            profileRepository: profileRepo,
            favoriteListsRepository: listsRepo,
            favoritesRepository: favoritesRepo
        )

        let result = try await useCase.handleTap(movieDetails: details)

        guard case .showPicker(let pickerMovie) = result else {
            fail("Expected showPicker")
            return
        }
        #expect(pickerMovie.id == details.id)
    }

    private func sampleMovieDetails() -> MovieDetails {
        MovieDetails(
            id: MovieID("m1"),
            title: "Movie",
            posterURL: nil,
            overview: nil,
            genres: [],
            imdbURL: nil
        )
    }
}
