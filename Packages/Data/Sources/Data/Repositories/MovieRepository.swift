import Foundation
import Domain

public struct MovieRepository: MovieRepositoryProtocol {
    private let apiClient: MovieAPIClient

    public init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.apiClient = MovieAPIClient(httpClient: httpClient)
    }

    public func search(query: String) async throws -> [Movie] {
        let response = try await apiClient.search(query: query)
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
        let response = try await apiClient.details(id: id.rawValue)
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
}
