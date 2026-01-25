import Domain

@MainActor
final class FavoritesRepositoryMock: FavoritesRepositoryProtocol, @unchecked Sendable {
    var favorites: Set<MovieID> = []

    func favorites(userId: UserID) async throws -> [Movie] {
        []
    }

    func favoritesStream(userId: UserID) -> AsyncStream<[Movie]> {
        AsyncStream { _ in }
    }

    func isFavorite(movieId: MovieID, userId: UserID) async throws -> Bool {
        favorites.contains(movieId)
    }

    func add(movie: MovieDetails, userId: UserID) async throws {
        favorites.insert(movie.id)
    }

    func remove(movieId: MovieID, userId: UserID) async throws {
        favorites.remove(movieId)
    }
}
