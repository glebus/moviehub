import Foundation
import Domain

public struct MovieDetailsPresentationModel: Sendable {
    public let id: MovieID
    public let title: String
    public let posterURL: URL?
    public let overview: String?
    public let genresText: String

    public init(
        id: MovieID,
        title: String,
        posterURL: URL?,
        overview: String?,
        genresText: String
    ) {
        self.id = id
        self.title = title
        self.posterURL = posterURL
        self.overview = overview
        self.genresText = genresText
    }
}

// State lives in MovieDetailsViewModel.
