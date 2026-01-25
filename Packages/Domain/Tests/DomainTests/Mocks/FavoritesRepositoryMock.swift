import Domain

actor FavoritesRepositoryMock: FavoritesRepositoryProtocol {
    private var favorites: [UserID: [Movie]] = [:]

    func fetchFavorites(userId: UserID) async throws -> [Movie] {
        favorites[userId] ?? []
    }

    func existsFavorite(userId: UserID, movieId: MovieID) async throws -> Bool {
        (favorites[userId] ?? []).contains { $0.id == movieId }
    }

    func addFavorite(userId: UserID, movie: MovieDetails) async throws {
        var list = favorites[userId] ?? []
        if !list.contains(where: { $0.id == movie.id }) {
            let item = Movie(
                id: movie.id,
                title: movie.title,
                year: nil,
                posterURL: movie.posterURL
            )
            list.append(item)
        }
        favorites[userId] = list
    }

    func removeFavorite(userId: UserID, movieId: MovieID) async throws {
        var list = favorites[userId] ?? []
        list.removeAll { $0.id == movieId }
        favorites[userId] = list
    }

    func seedFavorites(_ movies: [Movie], for userId: UserID) {
        favorites[userId] = movies
    }
}
