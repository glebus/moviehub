import Combine
import DomainModels
import DomainRepositories

@MainActor
public final class SessionRepository: ProfileRepositoryProtocol {
    private let storage: SwiftDataStorage
    private var currentUserSubject = CurrentValueSubject<User?, Never>(nil)
    public var currentUserSequence: any AsyncSequence<User?, Never> { currentUserSubject.values }
    public var currentUser: User? { currentUserSubject.value }

    public init(storage: SwiftDataStorage) {
        self.storage = storage
    }

    public func findUser(username: String) async throws -> User? {
        try await storage.findUser(username: username)
    }

    public func createUser(username: String) async throws -> User {
        try await storage.createUser(username: username)
    }

    public func setCurrentUser(_ user: User?) {
        currentUserSubject.send(user)
    }
}
