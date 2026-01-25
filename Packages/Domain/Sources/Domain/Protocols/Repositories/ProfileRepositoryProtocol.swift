@MainActor
public protocol ProfileRepositoryProtocol: Sendable {
    func currentUser() -> User?
    var currentUserStream: AsyncStream<User?> { get }

    func login(username: String) async throws -> User
    func logout() async
}
