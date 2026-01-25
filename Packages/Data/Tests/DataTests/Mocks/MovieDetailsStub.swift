import Foundation
import Domain

enum MovieDetailsStub {
    static func make(
        id: String = "movie-1",
        title: String = "Test Movie",
        posterURL: URL? = nil,
        overview: String? = nil,
        genres: [String] = []
    ) -> MovieDetails {
        MovieDetails(
            id: MovieID(id),
            title: title,
            posterURL: posterURL,
            overview: overview,
            genres: genres,
            imdbURL: nil
        )
    }
}
