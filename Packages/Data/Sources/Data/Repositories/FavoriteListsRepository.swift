import Observation
import DomainModels
import DomainRepositories

@MainActor
@Observable
public final class FavoriteListsRepository: FavoriteListsRepositoryProtocol {
    private let storage: SwiftDataStorage
    private let listsState = ObservableValue<[FavoriteList]>([])
    public var listsSequence: any AsyncSequence<[FavoriteList], Never> { listsState.updates }
    public var lists: [FavoriteList] { listsState.value }

    public init(storage: SwiftDataStorage) {
        self.storage = storage
    }

    public func fetchLists(userId: UserID) async throws -> [FavoriteList] {
        let fetched = try await storage.fetchLists(userId: userId)
        applyLists(fetched)
        return fetched
    }

    public func createList(userId: UserID, name: String, color: FavoriteListColor) async throws -> FavoriteList {
        let created = try await storage.createList(userId: userId, name: name, color: color)
        var updated = lists
        updated.append(created)
        applyLists(updated)
        return created
    }

    public func renameList(userId: UserID, listId: FavoriteListID, name: String) async throws {
        try await storage.renameList(userId: userId, listId: listId, name: name)
        if let index = lists.firstIndex(where: { $0.id == listId }) {
            var updated = lists
            let current = updated[index]
            updated[index] = FavoriteList(
                id: current.id,
                name: name,
                color: current.color,
                createdAt: current.createdAt
            )
            applyLists(updated)
        }
    }

    public func deleteList(userId: UserID, listId: FavoriteListID) async throws {
        try await storage.deleteList(userId: userId, listId: listId)
        applyLists(lists.filter { $0.id != listId })
    }

    public func clearLists() {
        applyLists([])
    }

    private func applyLists(_ lists: [FavoriteList]) {
        listsState.send(lists)
    }
}
