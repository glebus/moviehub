import Foundation
import Domain

@MainActor
public final class ProfileRepository: ProfileRepositoryProtocol {
    private let storage: ProfileStorageProtocol
    private let subject: AsyncStreamSubject<User?>
    private var currentUserSnapshot: User?

    public init(storage: ProfileStorageProtocol) {
        self.storage = storage
        self.subject = AsyncStreamSubject()
    }

    public func currentUser() -> User? {
        currentUserSnapshot
    }

    public var currentUserStream: AsyncStream<User?> {
        subject.stream()
    }

    public func login(username: String) async throws -> User {
        let normalized = UsernameNormalizer.normalize(username)
        if let existing = try await storage.findUser(username: normalized) {
            setCurrentUser(existing)
            await subject.send(existing)
            return existing
        }

        let created = try await storage.createUser(username: normalized)
        setCurrentUser(created)
        await subject.send(created)
        return created
    }

    public func logout() async {
        setCurrentUser(nil)
        await subject.send(nil)
    }

    private func setCurrentUser(_ user: User?) {
        currentUserSnapshot = user
    }
}
