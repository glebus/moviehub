import Foundation

struct MovieDetailsResponseDTO: Decodable, Sendable {
    let id: Int
    let title: String
    let overview: String?
    let releaseDate: String?
    let posterPath: String?
    let genres: [GenreDTO]

    struct GenreDTO: Decodable, Sendable {
        let id: Int
        let name: String
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case genres
    }
}
