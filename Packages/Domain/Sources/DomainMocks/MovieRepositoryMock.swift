import Domain

public struct MovieRepositoryMock: MovieRepositoryProtocol {
    public var searchResults: [Movie]
    public var detailsResult: MovieDetails

    public init(
        searchResults: [Movie] = [],
        detailsResult: MovieDetails = MovieDetails(
            id: MovieID(""),
            title: "",
            posterURL: nil,
            overview: nil,
            genres: [],
            imdbURL: nil
        )
    ) {
        self.searchResults = searchResults
        self.detailsResult = detailsResult
    }

    public func search(query: String) async throws -> [Movie] {
        searchResults
    }

    public func details(id: MovieID) async throws -> MovieDetails {
        if detailsResult.id.rawValue.isEmpty {
            return MovieDetails(
                id: id,
                title: "",
                posterURL: nil,
                overview: nil,
                genres: [],
                imdbURL: nil
            )
        }
        return detailsResult
    }
}
