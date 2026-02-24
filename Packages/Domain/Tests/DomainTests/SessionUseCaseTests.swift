import Testing
import DomainModels
import DomainUseCases
import DomainMocks

@MainActor
struct SessionUseCaseTests {
    @Test
    func loginSetsCurrentUser() async throws {
        let profileRepo = ProfileRepositoryMock()
        let listsRepo = FavoriteListsRepositoryMock()
        let favoritesRepo = FavoritesRepositoryMock()
        let loginUseCase = LoginUseCase(
            profileRepository: profileRepo,
            favoriteListsRepository: listsRepo,
            favoritesRepository: favoritesRepo
        )

        let loggedInUser = try await loginUseCase.login(username: "  Alice  ")

        #expect(profileRepo.currentUser == loggedInUser)
    }

    @Test
    func logoutClearsCurrentUser() async throws {
        let profileRepo = ProfileRepositoryMock()
        let listsRepo = FavoriteListsRepositoryMock()
        let favoritesRepo = FavoritesRepositoryMock()
        let loginUseCase = LoginUseCase(
            profileRepository: profileRepo,
            favoriteListsRepository: listsRepo,
            favoritesRepository: favoritesRepo
        )
        let logoutUseCase = LogoutUseCase(
            profileRepository: profileRepo,
            favoriteListsRepository: listsRepo,
            favoritesRepository: favoritesRepo
        )
        _ = try await loginUseCase.login(username: "Bob")

        await logoutUseCase.logout()

        #expect(profileRepo.currentUser == nil)
    }
}
