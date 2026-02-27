import DomainModels
import DomainRepositories

@MainActor
public final class SessionRepository: ProfileRepositoryProtocol {
    private let storage: SwiftDataStorage
    private let currentUserState = ObservableValue<User?>(nil)
    public var currentUserSequence: any AsyncSequence<User?, Never> { currentUserState.updates }
    public var currentUser: User? { currentUserState.value }

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
        currentUserState.send(user)
    }
}
