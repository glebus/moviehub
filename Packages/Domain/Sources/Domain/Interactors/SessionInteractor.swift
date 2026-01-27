import Foundation

@MainActor
public final class SessionInteractor: SessionInteractorProtocol {
    private let profileRepository: ProfileRepositoryProtocol
    private let subject: AsyncStreamSubject<User?>
    private var currentUserCache: User?

    public init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
        self.subject = AsyncStreamSubject(initial: nil)
    }

    public func currentUser() -> User? {
        currentUserCache
    }

    public var currentUserStream: AsyncStream<User?> {
        subject.stream
    }

    public func login(username: String) async throws -> User {
        let normalized = UsernameNormalizer.normalize(username)
        if let existing = try await profileRepository.findUser(username: normalized) {
            currentUserCache = existing
            await subject.send(existing)
            return existing
        }

        let created = try await profileRepository.createUser(username: normalized)
        currentUserCache = created
        await subject.send(created)
        return created
    }

    public func logout() async {
        currentUserCache = nil
        await subject.send(nil)
    }
}
