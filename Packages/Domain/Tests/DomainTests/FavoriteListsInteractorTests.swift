import Foundation
import Testing
@testable import Domain
import DomainMocks

@MainActor
struct FavoriteListsInteractorTests {
    @Test
    func refreshLoadsLists() async throws {
        let listsRepo = FavoriteListsRepositoryMock()
        let session = SessionInteractorMock()
        let interactor = FavoriteListsInteractor(listsRepository: listsRepo, sessionInteractor: session)

        #expect(interactor.lists == [])

        let user = try await session.login(username: "user")
        let seeded = FavoriteList(
            id: FavoriteListID("l1"),
            name: "Comedies",
            color: .mint,
            createdAt: Date()
        )
        await listsRepo.seedLists([seeded], for: user.id)

        try await interactor.refresh()
        #expect(interactor.lists == [seeded])
    }

    @Test
    func handleSessionChangeClearsListsOnLogout() async throws {
        let listsRepo = FavoriteListsRepositoryMock()
        let session = SessionInteractorMock()
        let interactor = FavoriteListsInteractor(listsRepository: listsRepo, sessionInteractor: session)

        let user = try await session.login(username: "user")
        let seeded = FavoriteList(
            id: FavoriteListID("l1"),
            name: "Comedies",
            color: .mint,
            createdAt: Date()
        )
        await listsRepo.seedLists([seeded], for: user.id)
        try await interactor.refresh()
        #expect(interactor.lists == [seeded])

        await interactor.handleSessionChange(nil)
        #expect(interactor.lists == [])
    }

    @Test
    func createRenameDeleteList() async throws {
        let listsRepo = FavoriteListsRepositoryMock()
        let session = SessionInteractorMock()
        let interactor = FavoriteListsInteractor(listsRepository: listsRepo, sessionInteractor: session)

        _ = try await session.login(username: "user")

        let created = try await interactor.create(name: "Comedies", color: .mint)
        #expect(interactor.lists.contains(created))

        try await interactor.rename(listId: created.id, name: "Funny")
        #expect(interactor.lists.first?.name == "Funny")

        try await interactor.delete(listId: created.id)
        #expect(interactor.lists.isEmpty)
    }
}
