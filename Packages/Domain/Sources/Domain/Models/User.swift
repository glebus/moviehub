import Foundation

public struct User: Equatable, Hashable, Codable, Sendable {
    public let id: UserID
    public let username: String

    public init(id: UserID, username: String) {
        self.id = id
        self.username = username
    }
}
