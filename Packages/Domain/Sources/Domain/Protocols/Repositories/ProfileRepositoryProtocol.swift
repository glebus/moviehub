public protocol ProfileRepositoryProtocol: Sendable {
    func findUser(username: String) async throws -> User?
    func createUser(username: String) async throws -> User
}
