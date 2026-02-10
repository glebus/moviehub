@MainActor
public protocol FavoriteListsInteractorProtocol: Sendable, AnyObject {
    var lists: [FavoriteList] { get }
    func refresh() async throws
    func create(name: String, color: FavoriteListColor) async throws -> FavoriteList
    func rename(listId: FavoriteListID, name: String) async throws
    func delete(listId: FavoriteListID) async throws
}
