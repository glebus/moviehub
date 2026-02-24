import Foundation

public struct FavoriteList: Identifiable, Hashable, Sendable {
    public let id: FavoriteListID
    public let name: String
    public let color: FavoriteListColor
    public let createdAt: Date

    public init(id: FavoriteListID, name: String, color: FavoriteListColor, createdAt: Date) {
        self.id = id
        self.name = name
        self.color = color
        self.createdAt = createdAt
    }
}
