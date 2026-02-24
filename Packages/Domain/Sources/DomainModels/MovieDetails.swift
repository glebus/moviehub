import Foundation

public struct MovieDetails: Equatable, Hashable, Codable, Sendable {
    public let id: MovieID
    public let title: String
    public let posterURL: URL?
    public let overview: String?
    public let genres: [String]
    public let imdbURL: URL?

    public init(
        id: MovieID,
        title: String,
        posterURL: URL?,
        overview: String?,
        genres: [String],
        imdbURL: URL?
    ) {
        self.id = id
        self.title = title
        self.posterURL = posterURL
        self.overview = overview
        self.genres = genres
        self.imdbURL = imdbURL
    }
}
