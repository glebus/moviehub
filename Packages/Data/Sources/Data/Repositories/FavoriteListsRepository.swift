import Combine
import Observation
import DomainModels
import DomainRepositories

@MainActor
@Observable
public final class FavoriteListsRepository: FavoriteListsRepositoryProtocol {
    private let storage: SwiftDataStorage
    private let listsSubject: CurrentValueSubject<[FavoriteList], Never>
    public private(set) var lists: [FavoriteList]
    public var listsSequence: any AsyncSequence<[FavoriteList], Never> { listsSubject.values }

    public init(storage: SwiftDataStorage) {
        self.storage = storage
        self.lists = []
        self.listsSubject = CurrentValueSubject([])
    }

    public func fetchLists(userId: UserID) async throws -> [FavoriteList] {
        let fetched = try await storage.fetchLists(userId: userId)
        lists = fetched
        listsSubject.send(fetched)
        return fetched
    }

    public func createList(userId: UserID, name: String, color: FavoriteListColor) async throws -> FavoriteList {
        let created = try await storage.createList(userId: userId, name: name, color: color)
        lists.append(created)
        listsSubject.send(lists)
        return created
    }

    public func renameList(userId: UserID, listId: FavoriteListID, name: String) async throws {
        try await storage.renameList(userId: userId, listId: listId, name: name)
        if let index = lists.firstIndex(where: { $0.id == listId }) {
            let current = lists[index]
            lists[index] = FavoriteList(
                id: current.id,
                name: name,
                color: current.color,
                createdAt: current.createdAt
            )
            listsSubject.send(lists)
        }
    }

    public func deleteList(userId: UserID, listId: FavoriteListID) async throws {
        try await storage.deleteList(userId: userId, listId: listId)
        lists.removeAll { $0.id == listId }
        listsSubject.send(lists)
    }

    public func clearLists() {
        lists = []
        listsSubject.send([])
    }
}
