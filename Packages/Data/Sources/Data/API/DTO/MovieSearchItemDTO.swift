import Foundation

struct MovieSearchItemDTO: Decodable, Sendable {
    let imdbId: String?
    let title: String?
    let year: String?
    let posterURL: String?

    enum CodingKeys: String, CodingKey {
        case imdbId = "#IMDB_ID"
        case title = "#TITLE"
        case year = "#YEAR"
        case posterURL = "#IMG_POSTER"
    }
}
