import Domain

@MainActor
public final class SessionInteractorMock: SessionInteractorProtocol {
    private let subject: AsyncStreamSubject<User?>
    private var currentUserCache: User?

    public init(currentUser: User? = nil) {
        self.currentUserCache = currentUser
        self.subject = AsyncStreamSubject(initial: currentUser)
    }

    public func currentUser() -> User? {
        currentUserCache
    }

    public var currentUserStream: AsyncStream<User?> {
        subject.stream
    }

    public func login(username: String) async throws -> User {
        let normalized = UsernameNormalizer.normalize(username)
        let user = User(id: UserID(normalized), username: normalized)
        currentUserCache = user
        await subject.send(user)
        return user
    }

    public func logout() async {
        currentUserCache = nil
        await subject.send(nil)
    }
}
