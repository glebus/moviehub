import Foundation

public protocol HTTPClient: Sendable {
    func get(url: URL) async throws -> Data
}
