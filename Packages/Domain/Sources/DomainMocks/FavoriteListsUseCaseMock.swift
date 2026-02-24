import Foundation
import Combine
import Observation
import DomainModels
import DomainUseCases

@MainActor
@Observable
public final class FavoriteListsUseCaseMock {
    public private(set) var lists: [FavoriteList]
    private let listsSubject: CurrentValueSubject<[FavoriteList], Never>
    public var listsSequence: any AsyncSequence<[FavoriteList], Never> { listsSubject.values }

    public init(lists: [FavoriteList] = []) {
        self.lists = lists
        self.listsSubject = CurrentValueSubject(lists)
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
        listsSubject.send(lists)
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
            listsSubject.send(lists)
        }
    }

    public func delete(listId: FavoriteListID) async throws {
        lists.removeAll { $0.id == listId }
        listsSubject.send(lists)
    }
}
