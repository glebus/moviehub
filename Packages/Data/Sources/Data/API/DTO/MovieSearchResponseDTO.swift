import Foundation

struct MovieSearchResponseDTO: Decodable, Sendable {
    let items: [MovieSearchItemDTO]

    enum CodingKeys: String, CodingKey {
        case items = "description"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([MovieSearchItemDTO].self, forKey: .items) ?? []
    }
}
