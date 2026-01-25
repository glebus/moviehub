import Foundation

struct MovieAPIClient: Sendable {
    private let httpClient: HTTPClient
    private let decoder: JSONDecoder
    private let baseURL: URL

    init(
        httpClient: HTTPClient,
        decoder: JSONDecoder = JSONDecoder(),
        baseURL: URL = URL(string: "https://imdb.iamidiotareyoutoo.com/search")!
    ) {
        self.httpClient = httpClient
        self.decoder = decoder
        self.baseURL = baseURL
    }

    func search(query: String) async throws -> MovieSearchResponseDTO {
        let url = try makeURL(queryItems: [URLQueryItem(name: "q", value: query)])
        let data = try await httpClient.get(url: url)
        return try decoder.decode(MovieSearchResponseDTO.self, from: data)
    }

    func details(id: String) async throws -> MovieDetailsResponseDTO {
        let url = try makeURL(queryItems: [URLQueryItem(name: "tt", value: id)])
        let data = try await httpClient.get(url: url)
        return try decoder.decode(MovieDetailsResponseDTO.self, from: data)
    }

    private func makeURL(queryItems: [URLQueryItem]) throws -> URL {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }
        components.queryItems = queryItems
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        return url
    }
}
