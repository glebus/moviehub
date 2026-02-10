import Observation
import Domain

@MainActor
@Observable
public final class SessionInteractorMock: SessionInteractorProtocol {
    public private(set) var currentUser: User?

    public init(currentUser: User? = nil) {
        self.currentUser = currentUser
    }

    public func login(username: String) async throws -> User {
        let normalized = UsernameNormalizer.normalize(username)
        let user = User(id: UserID(normalized), username: normalized)
        currentUser = user
        return user
    }

    public func logout() async {
        currentUser = nil
    }
}
