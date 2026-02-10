public protocol FavoriteListsRepositoryProtocol: Sendable {
    func fetchLists(userId: UserID) async throws -> [FavoriteList]
    func createList(userId: UserID, name: String, color: FavoriteListColor) async throws -> FavoriteList
    func renameList(userId: UserID, listId: FavoriteListID, name: String) async throws
    func deleteList(userId: UserID, listId: FavoriteListID) async throws
}
