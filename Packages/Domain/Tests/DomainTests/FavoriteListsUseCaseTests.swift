import Foundation
import Testing
@testable import DomainModels
import DomainUseCases
import DomainMocks

@MainActor
struct FavoriteListsUseCaseTests {
    @Test
    func refreshLoadsLists() async throws {
        let profileRepo = ProfileRepositoryMock()
        let listsRepo = FavoriteListsRepositoryMock()
        let refreshUseCase = RefreshFavoriteListsUseCase(
            listsRepository: listsRepo,
            profileRepository: profileRepo
        )

        #expect(listsRepo.lists == [])

        let user = User(id: UserID("user"), username: "user")
        profileRepo.setCurrentUser(user)
        let seeded = FavoriteList(
            id: FavoriteListID("l1"),
            name: "Comedies",
            color: .mint,
            createdAt: Date()
        )
        listsRepo.seedLists([seeded], for: user.id)

        try await refreshUseCase.refresh()
        #expect(listsRepo.lists == [seeded])
    }

    @Test
    func logoutClearsListsThroughRepositoryState() async throws {
        let profileRepo = ProfileRepositoryMock()
        let listsRepo = FavoriteListsRepositoryMock()
        let refreshUseCase = RefreshFavoriteListsUseCase(
            listsRepository: listsRepo,
            profileRepository: profileRepo
        )
        let logoutUseCase = LogoutUseCase(
            profileRepository: profileRepo,
            favoriteListsRepository: listsRepo
        )

        let user = User(id: UserID("user"), username: "user")
        profileRepo.setCurrentUser(user)
        let seeded = FavoriteList(
            id: FavoriteListID("l1"),
            name: "Comedies",
            color: .mint,
            createdAt: Date()
        )
        listsRepo.seedLists([seeded], for: user.id)
        try await refreshUseCase.refresh()
        #expect(listsRepo.lists == [seeded])

        await logoutUseCase.logout()

        #expect(listsRepo.lists == [])
    }

    @Test
    func createRenameDeleteList() async throws {
        let profileRepo = ProfileRepositoryMock()
        let listsRepo = FavoriteListsRepositoryMock()
        let createUseCase = CreateFavoriteListUseCase(
            listsRepository: listsRepo,
            profileRepository: profileRepo
        )
        let renameUseCase = RenameFavoriteListUseCase(
            listsRepository: listsRepo,
            profileRepository: profileRepo
        )
        let deleteUseCase = DeleteFavoriteListUseCase(
            listsRepository: listsRepo,
            profileRepository: profileRepo
        )

        profileRepo.setCurrentUser(User(id: UserID("user"), username: "user"))

        let created = try await createUseCase.create(name: "Comedies", color: .mint)
        #expect(listsRepo.lists.contains(created))

        try await renameUseCase.rename(listId: created.id, name: "Funny")
        #expect(listsRepo.lists.first?.name == "Funny")

        try await deleteUseCase.delete(listId: created.id)
        #expect(listsRepo.lists.isEmpty)
    }
}
