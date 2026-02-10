import Foundation
import SwiftData

@Model
final class SDFavoriteList {
    var id: String
    var userId: String
    var name: String
    var colorRaw: String
    var createdAt: Date

    init(
        id: String,
        userId: String,
        name: String,
        colorRaw: String,
        createdAt: Date
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.colorRaw = colorRaw
        self.createdAt = createdAt
    }
}
