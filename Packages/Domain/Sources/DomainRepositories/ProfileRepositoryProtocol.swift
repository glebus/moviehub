import DomainModels

@MainActor
public protocol ProfileRepositoryProtocol: Sendable {
    var currentUser: User? { get }
    var currentUserSequence: any AsyncSequence<User?, Never> { get }
    func findUser(username: String) async throws -> User?
    func createUser(username: String) async throws -> User
    func setCurrentUser(_ user: User?)
}
