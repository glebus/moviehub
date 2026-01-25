import Foundation
import SwiftData

@Model
final class SDUser {
    var id: String
    var username: String
    var createdAt: Date

    init(id: String, username: String, createdAt: Date) {
        self.id = id
        self.username = username
        self.createdAt = createdAt
    }
}
