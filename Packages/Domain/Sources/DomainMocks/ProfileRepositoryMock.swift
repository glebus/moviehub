import Domain

public actor ProfileRepositoryMock: ProfileRepositoryProtocol {
    private var users: [String: User] = [:]

    public init() {}

    public func findUser(username: String) async throws -> User? {
        users[username]
    }

    public func createUser(username: String) async throws -> User {
        let user = User(id: UserID(username), username: username)
        users[username] = user
        return user
    }
}
