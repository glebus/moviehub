@MainActor
public protocol SessionInteractorProtocol: Sendable, AnyObject {
    var currentUser: User? { get }
    func login(username: String) async throws -> User
    func logout() async
}
