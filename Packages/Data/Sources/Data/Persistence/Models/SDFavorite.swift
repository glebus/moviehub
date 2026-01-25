import Foundation
import SwiftData

@Model
final class SDFavorite {
    var userId: String
    var movieId: String
    var title: String
    var year: String?
    var posterURL: String?
    var createdAt: Date

    init(
        userId: String,
        movieId: String,
        title: String,
        year: String?,
        posterURL: String?,
        createdAt: Date
    ) {
        self.userId = userId
        self.movieId = movieId
        self.title = title
        self.year = year
        self.posterURL = posterURL
        self.createdAt = createdAt
    }
}
