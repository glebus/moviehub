import Foundation

enum TMDbImageURLBuilder {
    static let posterBase = "https://image.tmdb.org/t/p/w500"

    static func posterURL(from posterPath: String?) -> URL? {
        guard let posterPath, !posterPath.isEmpty else {
            return nil
        }
        return URL(string: posterBase + posterPath)
    }
}
