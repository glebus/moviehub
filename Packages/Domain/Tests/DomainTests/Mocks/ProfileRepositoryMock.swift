import Domain

actor ProfileRepositoryMock: ProfileRepositoryProtocol {
    private var users: [String: User] = [:]

    func findUser(username: String) async throws -> User? {
        users[username]
    }

    func createUser(username: String) async throws -> User {
        let user = User(id: UserID(username), username: username)
        users[username] = user
        return user
    }
}
