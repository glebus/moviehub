import Foundation
import Domain

public actor FavoriteListsRepositoryMock: FavoriteListsRepositoryProtocol {
    private var lists: [UserID: [FavoriteList]] = [:]

    public init() {}

    public func fetchLists(userId: UserID) async throws -> [FavoriteList] {
        lists[userId] ?? []
    }

    public func createList(userId: UserID, name: String, color: FavoriteListColor) async throws -> FavoriteList {
        let created = FavoriteList(
            id: FavoriteListID(UUID().uuidString),
            name: name,
            color: color,
            createdAt: Date()
        )
        var userLists = lists[userId] ?? []
        userLists.append(created)
        lists[userId] = userLists
        return created
    }

    public func renameList(userId: UserID, listId: FavoriteListID, name: String) async throws {
        var userLists = lists[userId] ?? []
        if let index = userLists.firstIndex(where: { $0.id == listId }) {
            let current = userLists[index]
            userLists[index] = FavoriteList(
                id: current.id,
                name: name,
                color: current.color,
                createdAt: current.createdAt
            )
            lists[userId] = userLists
        }
    }

    public func deleteList(userId: UserID, listId: FavoriteListID) async throws {
        var userLists = lists[userId] ?? []
        userLists.removeAll { $0.id == listId }
        lists[userId] = userLists
    }

    public func seedLists(_ seed: [FavoriteList], for userId: UserID) {
        lists[userId] = seed
    }
}
