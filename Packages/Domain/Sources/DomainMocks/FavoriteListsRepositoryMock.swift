import Foundation
import Combine
import Observation
import DomainModels
import DomainUseCases
import DomainRepositories

@MainActor
@Observable
public final class FavoriteListsRepositoryMock: FavoriteListsRepositoryProtocol {
    private var storageByUser: [UserID: [FavoriteList]] = [:]
    public private(set) var lists: [FavoriteList] = []
    private let listsSubject = CurrentValueSubject<[FavoriteList], Never>([])
    public var listsSequence: any AsyncSequence<[FavoriteList], Never> { listsSubject.values }

    public init() {}

    public func fetchLists(userId: UserID) async throws -> [FavoriteList] {
        let fetched = storageByUser[userId] ?? []
        lists = fetched
        listsSubject.send(fetched)
        return fetched
    }

    public func createList(userId: UserID, name: String, color: FavoriteListColor) async throws -> FavoriteList {
        let created = FavoriteList(
            id: FavoriteListID(UUID().uuidString),
            name: name,
            color: color,
            createdAt: Date()
        )
        var userLists = storageByUser[userId] ?? []
        userLists.append(created)
        storageByUser[userId] = userLists
        lists = userLists
        listsSubject.send(userLists)
        return created
    }

    public func renameList(userId: UserID, listId: FavoriteListID, name: String) async throws {
        var userLists = storageByUser[userId] ?? []
        if let index = userLists.firstIndex(where: { $0.id == listId }) {
            let current = userLists[index]
            userLists[index] = FavoriteList(
                id: current.id,
                name: name,
                color: current.color,
                createdAt: current.createdAt
            )
            storageByUser[userId] = userLists
            lists = userLists
            listsSubject.send(userLists)
        }
    }

    public func deleteList(userId: UserID, listId: FavoriteListID) async throws {
        var userLists = storageByUser[userId] ?? []
        userLists.removeAll { $0.id == listId }
        storageByUser[userId] = userLists
        lists = userLists
        listsSubject.send(userLists)
    }

    public func clearLists() {
        lists = []
        listsSubject.send([])
    }

    public func seedLists(_ seed: [FavoriteList], for userId: UserID) {
        storageByUser[userId] = seed
    }
}
