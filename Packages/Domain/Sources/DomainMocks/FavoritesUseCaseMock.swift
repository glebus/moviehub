import Combine
import Observation
import DomainModels
import DomainUseCases

@MainActor
@Observable
public final class FavoritesUseCaseMock {
    public private(set) var favoritesByList: [FavoriteListID: [Movie]]
    private let favoritesByListSubject: CurrentValueSubject<[FavoriteListID: [Movie]], Never>
    public var favoritesByListSequence: any AsyncSequence<[FavoriteListID: [Movie]], Never> {
        favoritesByListSubject.values
    }
    public private(set) var favoriteListByMovie: [MovieID: FavoriteListID]
    private let favoriteListByMovieSubject: CurrentValueSubject<[MovieID: FavoriteListID], Never>
    public var favoriteListByMovieSequence: any AsyncSequence<[MovieID: FavoriteListID], Never> {
        favoriteListByMovieSubject.values
    }

    public init(
        favoritesByList: [FavoriteListID: [Movie]] = [:],
        favoriteListByMovie: [MovieID: FavoriteListID] = [:]
    ) {
        self.favoritesByList = favoritesByList
        self.favoriteListByMovie = favoriteListByMovie
        self.favoritesByListSubject = CurrentValueSubject(favoritesByList)
        self.favoriteListByMovieSubject = CurrentValueSubject(favoriteListByMovie)
    }

    public func refreshFavorites(listId: FavoriteListID) async throws {}

    public func addFavorite(movie: MovieDetails, listId: FavoriteListID) async throws {
        var movies = favoritesByList[listId] ?? []
        if !movies.contains(where: { $0.id == movie.id }) {
            movies.append(Movie(id: movie.id, title: movie.title, year: nil, posterURL: movie.posterURL))
        }
        favoritesByList[listId] = movies
        favoriteListByMovie[movie.id] = listId
        favoritesByListSubject.send(favoritesByList)
        favoriteListByMovieSubject.send(favoriteListByMovie)
    }

    public func removeFavorite(movieId: MovieID) async throws {
        if let listId = favoriteListByMovie[movieId] {
            favoritesByList[listId]?.removeAll { $0.id == movieId }
        }
        favoriteListByMovie[movieId] = nil
        favoritesByListSubject.send(favoritesByList)
        favoriteListByMovieSubject.send(favoriteListByMovie)
    }

    public func favoriteListId(movieId: MovieID) async throws -> FavoriteListID? {
        favoriteListByMovie[movieId]
    }
}
