import Foundation

struct MovieSearchResponseDTO: Decodable, Sendable {
    let items: [MovieSearchItemDTO]

    enum CodingKeys: String, CodingKey {
        case items = "results"
    }
}
