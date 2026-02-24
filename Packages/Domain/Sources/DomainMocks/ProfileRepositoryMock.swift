import Combine
import Observation
import DomainModels
import DomainUseCases
import DomainRepositories

@MainActor
@Observable
public final class ProfileRepositoryMock: ProfileRepositoryProtocol {
    private var users: [String: User] = [:]
    public private(set) var currentUser: User?
    private let currentUserSubject = CurrentValueSubject<User?, Never>(nil)
    public var currentUserSequence: any AsyncSequence<User?, Never> { currentUserSubject.values }

    public init() {}

    public func findUser(username: String) async throws -> User? {
        users[username]
    }

    public func createUser(username: String) async throws -> User {
        let user = User(id: UserID(username), username: username)
        users[username] = user
        return user
    }

    public func setCurrentUser(_ user: User?) {
        currentUser = user
        currentUserSubject.send(user)
    }
}
