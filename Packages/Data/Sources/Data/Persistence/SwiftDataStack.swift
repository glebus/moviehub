import Foundation
import SwiftData

public struct SwiftDataStack: Sendable {
    public let container: ModelContainer

    public init(inMemory: Bool) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        do {
            container = try ModelContainer(for: SDUser.self, SDFavorite.self, configurations: configuration)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
