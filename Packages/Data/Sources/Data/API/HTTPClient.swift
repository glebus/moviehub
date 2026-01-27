import Foundation

public protocol HTTPClient: Sendable {
    func get(url: URL, headers: [String: String]) async throws -> Data
}

public extension HTTPClient {
    func get(url: URL) async throws -> Data {
        try await get(url: url, headers: [:])
    }
}
