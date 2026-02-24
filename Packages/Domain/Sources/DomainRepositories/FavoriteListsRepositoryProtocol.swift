import DomainModels

@MainActor
public protocol FavoriteListsRepositoryProtocol: Sendable {
    var lists: [FavoriteList] { get }
    var listsSequence: any AsyncSequence<[FavoriteList], Never> { get }
    func fetchLists(userId: UserID) async throws -> [FavoriteList]
    func createList(userId: UserID, name: String, color: FavoriteListColor) async throws -> FavoriteList
    func renameList(userId: UserID, listId: FavoriteListID, name: String) async throws
    func deleteList(userId: UserID, listId: FavoriteListID) async throws
    func clearLists()
}
