import Foundation

struct MovieDetailsResponseDTO: Decodable, Sendable {
    let short: ShortDTO?

    struct ShortDTO: Decodable, Sendable {
        let name: String?
        let image: String?
        let description: String?
        let genre: [String]
        let url: String?

        enum CodingKeys: String, CodingKey {
            case name
            case image
            case description
            case genre
            case url
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decodeIfPresent(String.self, forKey: .name)
            image = try container.decodeIfPresent(String.self, forKey: .image)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            url = try container.decodeIfPresent(String.self, forKey: .url)
            genre = try ShortDTO.decodeGenre(from: container)
        }

        private static func decodeGenre(from container: KeyedDecodingContainer<CodingKeys>) throws -> [String] {
            if let stringValue = try container.decodeIfPresent(String.self, forKey: .genre) {
                return stringValue
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            }
            if let arrayValue = try container.decodeIfPresent([String].self, forKey: .genre) {
                return arrayValue
            }
            return []
        }
    }
}
