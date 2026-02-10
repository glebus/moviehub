import Observation
import Domain

@MainActor
@Observable
public final class FavoritesInteractorMock: FavoritesInteractorProtocol {
    public private(set) var favorites: [Movie]

    public init(favorites: [Movie] = []) {
        self.favorites = favorites
    }

    public func refresh() async throws {
        favorites = Array(favorites)
    }

    public func toggle(movie: MovieDetails) async throws -> Bool {
        if let index = favorites.firstIndex(where: { $0.id == movie.id }) {
            favorites.remove(at: index)
            return false
        }

        let item = Movie(id: movie.id, title: movie.title, year: nil, posterURL: movie.posterURL)
        favorites.append(item)
        return true
    }

    public func isFavorite(movieId: MovieID) -> Bool {
        favorites.contains { $0.id == movieId }
    }
}
