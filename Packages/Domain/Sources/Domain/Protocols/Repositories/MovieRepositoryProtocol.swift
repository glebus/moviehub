public protocol MovieRepositoryProtocol: Sendable {
    func search(query: String) async throws -> [Movie]
    func details(id: MovieID) async throws -> MovieDetails
}
