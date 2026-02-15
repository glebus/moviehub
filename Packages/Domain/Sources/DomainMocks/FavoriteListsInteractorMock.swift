import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class FavoriteListsInteractorMock: FavoriteListsInteractorProtocol {
    public private(set) var lists: [FavoriteList]

    public init(lists: [FavoriteList] = []) {
        self.lists = lists
    }

    public func refresh() async throws {}

    public func create(name: String, color: FavoriteListColor) async throws -> FavoriteList {
        let list = FavoriteList(
            id: FavoriteListID(UUID().uuidString),
            name: name,
            color: color,
            createdAt: Date()
        )
        lists.append(list)
        return list
    }

    public func rename(listId: FavoriteListID, name: String) async throws {
        if let index = lists.firstIndex(where: { $0.id == listId }) {
            let updated = FavoriteList(
                id: lists[index].id,
                name: name,
                color: lists[index].color,
                createdAt: lists[index].createdAt
            )
            lists[index] = updated
        }
    }

    public func delete(listId: FavoriteListID) async throws {
        lists.removeAll { $0.id == listId }
    }
}
