import Domain

@MainActor
final class ProfileRepositoryMock: ProfileRepositoryProtocol, @unchecked Sendable {
    var user: User?

    func currentUser() -> User? {
        user
    }

    var currentUserStream: AsyncStream<User?> {
        AsyncStream { _ in }
    }

    func login(username: String) async throws -> User {
        let user = User(id: UserID("mock"), username: username)
        self.user = user
        return user
    }

    func logout() async {
        user = nil
    }
}
