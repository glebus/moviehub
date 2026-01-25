import Foundation
import Domain

public struct MovieRepository: MovieRepositoryProtocol {
    private let httpClient: HTTPClient
    private let decoder: JSONDecoder
    private let baseURL: URL

    public init(
        httpClient: HTTPClient = URLSessionHTTPClient(),
        decoder: JSONDecoder = JSONDecoder(),
        baseURL: URL = URL(string: "https://imdb.iamidiotareyoutoo.com/search")!
    ) {
        self.httpClient = httpClient
        self.decoder = decoder
        self.baseURL = baseURL
    }

    public func search(query: String) async throws -> [Movie] {
        let url = try makeURL(queryItems: [URLQueryItem(name: "q", value: query)])
        let data = try await httpClient.get(url: url)
        let response = try decoder.decode(MovieSearchResponseDTO.self, from: data)
        return response.items.compactMap { item in
            guard let id = item.imdbId, let title = item.title else {
                return nil
            }
            return Movie(
                id: MovieID(id),
                title: title,
                year: item.year,
                posterURL: item.posterURL.flatMap(URL.init(string:))
            )
        }
    }

    public func details(id: MovieID) async throws -> MovieDetails {
        let url = try makeURL(queryItems: [URLQueryItem(name: "tt", value: id.rawValue)])
        let data = try await httpClient.get(url: url)
        let response = try decoder.decode(MovieDetailsResponseDTO.self, from: data)
        let details = response.short
        return MovieDetails(
            id: id,
            title: details?.name ?? "",
            posterURL: details?.image.flatMap(URL.init(string:)),
            overview: details?.description,
            genres: details?.genre ?? [],
            imdbURL: details?.url.flatMap(URL.init(string:))
        )
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
