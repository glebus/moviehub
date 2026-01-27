import Foundation
import Domain

public struct MovieRepository: MovieRepositoryProtocol {
    private let httpClient: HTTPClient
    private let decoder: JSONDecoder
    private let baseURL: URL
    private let readAccessToken: String
    private let apiVersionPath = "/3"

    public init(
        httpClient: HTTPClient = URLSessionHTTPClient(),
        decoder: JSONDecoder = JSONDecoder(),
        baseURL: URL = URL(string: "https://api.themoviedb.org")!,
        readAccessToken: String
    ) {
        self.httpClient = httpClient
        self.decoder = decoder
        self.baseURL = baseURL
        self.readAccessToken = readAccessToken
    }

    public func search(query: String) async throws -> [Movie] {
        let url = try makeURL(
            path: "/search/movie",
            queryItems: [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "include_adult", value: "false")
            ]
        )
        let data = try await httpClient.get(url: url, headers: authorizationHeaders())
        let response = try decoder.decode(MovieSearchResponseDTO.self, from: data)
        return response.items.map { item in
            Movie(
                id: MovieID(String(item.id)),
                title: item.title,
                year: item.releaseDate.flatMap(parseYear),
                posterURL: TMDbImageURLBuilder.posterURL(from: item.posterPath)
            )
        }
    }

    public func details(id: MovieID) async throws -> MovieDetails {
        let url = try makeURL(path: "/movie/\(id.rawValue)")
        let data = try await httpClient.get(url: url, headers: authorizationHeaders())
        let response = try decoder.decode(MovieDetailsResponseDTO.self, from: data)
        return MovieDetails(
            id: id,
            title: response.title,
            posterURL: TMDbImageURLBuilder.posterURL(from: response.posterPath),
            overview: response.overview,
            genres: response.genres.map(\.name),
            imdbURL: nil
        )
    }

    private func makeURL(path: String, queryItems: [URLQueryItem] = []) throws -> URL {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }
        components.path = apiVersionPath + path
        components.queryItems = queryItems
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        return url
    }

    private func authorizationHeaders() -> [String: String] {
        guard !readAccessToken.isEmpty else {
            return [:]
        }
        return ["Authorization": "Bearer \(readAccessToken)"]
    }

    private func parseYear(from releaseDate: String) -> String? {
        guard releaseDate.count >= 4 else {
            return nil
        }
        return String(releaseDate.prefix(4))
    }
}
