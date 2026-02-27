import Foundation
import Testing
@testable import DomainModels
import DomainUseCases
import DomainMocks

@MainActor
struct LookupCurrentUserFavoriteListsUseCaseTests {
    @Test
    func returnsRequireAuthWhenNoSession() async throws {
        let profileRepo = ProfileRepositoryMock()
        let favoritesRepo = FavoritesRepositoryMock()
        let useCase = LookupCurrentUserFavoriteListsUseCase(
            profileRepository: profileRepo,
            favoritesRepository: favoritesRepo
        )

        let result = try await useCase.favoriteListIds(movieId: MovieID("m1"))

        guard case .requireAuth = result else {
            fail("Expected requireAuth")
            return
        }
    }

    @Test
    func returnsFavoriteListIdsForCurrentUser() async throws {
        let profileRepo = ProfileRepositoryMock()
        let favoritesRepo = FavoritesRepositoryMock()
        let user = User(id: UserID("u1"), username: "alex")
        let listId = FavoriteListID("l1")
        profileRepo.setCurrentUser(user)
        favoritesRepo.seedFavorites([
            Movie(id: MovieID("m1"), title: "Movie", year: nil, posterURL: nil)
        ], for: user.id, listId: listId)

        let useCase = LookupCurrentUserFavoriteListsUseCase(
            profileRepository: profileRepo,
            favoritesRepository: favoritesRepo
        )

        let result = try await useCase.favoriteListIds(movieId: MovieID("m1"))

        guard case .favoriteListIDs(let listIDs) = result else {
            fail("Expected favoriteListIDs")
            return
        }
        #expect(listIDs == [listId])
    }

    @Test
    func returnsEmptyFavoriteListIdsWhenMovieNotFavorite() async throws {
        let profileRepo = ProfileRepositoryMock()
        let favoritesRepo = FavoritesRepositoryMock()
        profileRepo.setCurrentUser(User(id: UserID("u1"), username: "alex"))
        let useCase = LookupCurrentUserFavoriteListsUseCase(
            profileRepository: profileRepo,
            favoritesRepository: favoritesRepo
        )

        let result = try await useCase.favoriteListIds(movieId: MovieID("missing"))

        guard case .favoriteListIDs(let listIDs) = result else {
            fail("Expected favoriteListIDs")
            return
        }
        #expect(listIDs.isEmpty)
    }
}
