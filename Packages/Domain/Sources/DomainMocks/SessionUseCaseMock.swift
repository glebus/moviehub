import Combine
import Observation
import DomainModels
import DomainUseCases

@MainActor
@Observable
public final class SessionUseCaseMock {
    public private(set) var currentUser: User?
    private let currentUserSubject: CurrentValueSubject<User?, Never>
    public var currentUserSequence: any AsyncSequence<User?, Never> { currentUserSubject.values }

    public init(currentUser: User? = nil) {
        self.currentUser = currentUser
        self.currentUserSubject = CurrentValueSubject(currentUser)
    }

    public func login(username: String) async throws -> User {
        let normalized = UsernameNormalizer.normalize(username)
        let user = User(id: UserID(normalized), username: normalized)
        currentUser = user
        currentUserSubject.send(user)
        return user
    }

    public func logout() async {
        currentUser = nil
        currentUserSubject.send(nil)
    }
}
