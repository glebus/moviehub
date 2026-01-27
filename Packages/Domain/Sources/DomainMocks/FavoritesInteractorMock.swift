import Domain

@MainActor
public final class FavoritesInteractorMock: FavoritesInteractorProtocol {
    private let subject: AsyncStreamSubject<[Movie]>
    private var favoritesCache: [Movie]

    public init(favorites: [Movie] = []) {
        self.favoritesCache = favorites
        self.subject = AsyncStreamSubject(initial: favorites)
    }

    public func favorites() -> [Movie] {
        favoritesCache
    }

    public var favoritesStream: AsyncStream<[Movie]> {
        subject.stream
    }

    public func refresh() async throws {
        await subject.send(favoritesCache)
    }

    public func toggle(movie: MovieDetails) async throws -> Bool {
        if let index = favoritesCache.firstIndex(where: { $0.id == movie.id }) {
            favoritesCache.remove(at: index)
            await subject.send(favoritesCache)
            return false
        }

        let item = Movie(id: movie.id, title: movie.title, year: nil, posterURL: movie.posterURL)
        favoritesCache.append(item)
        await subject.send(favoritesCache)
        return true
    }

    public func isFavorite(movieId: MovieID) -> Bool {
        favoritesCache.contains { $0.id == movieId }
    }
}
