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
    public private(set) var favoriteListsByMovie: [MovieID: Set<FavoriteListID>]
    private let favoriteListsByMovieSubject: CurrentValueSubject<[MovieID: Set<FavoriteListID>], Never>
    public var favoriteListsByMovieSequence: any AsyncSequence<[MovieID: Set<FavoriteListID>], Never> {
        favoriteListsByMovieSubject.values
    }

    public init(
        favoritesByList: [FavoriteListID: [Movie]] = [:],
        favoriteListsByMovie: [MovieID: Set<FavoriteListID>] = [:]
    ) {
        self.favoritesByList = favoritesByList
        self.favoriteListsByMovie = favoriteListsByMovie
        self.favoritesByListSubject = CurrentValueSubject(favoritesByList)
        self.favoriteListsByMovieSubject = CurrentValueSubject(favoriteListsByMovie)
    }

    public func refreshFavorites(listId: FavoriteListID) async throws -> [Movie] {
        favoritesByList[listId] ?? []
    }

    public func addFavorite(movie: MovieDetails, listId: FavoriteListID) async throws {
        var movies = favoritesByList[listId] ?? []
        if !movies.contains(where: { $0.id == movie.id }) {
            movies.append(Movie(id: movie.id, title: movie.title, year: nil, posterURL: movie.posterURL))
        }
        favoritesByList[listId] = movies
        favoriteListsByMovie[movie.id, default: []].insert(listId)
        favoritesByListSubject.send(favoritesByList)
        favoriteListsByMovieSubject.send(favoriteListsByMovie)
    }

    public func removeFavorite(movieId: MovieID, listId: FavoriteListID) async throws {
        favoritesByList[listId]?.removeAll { $0.id == movieId }
        if var memberships = favoriteListsByMovie[movieId] {
            memberships.remove(listId)
            favoriteListsByMovie[movieId] = memberships.isEmpty ? nil : memberships
        }
        favoritesByListSubject.send(favoritesByList)
        favoriteListsByMovieSubject.send(favoriteListsByMovie)
    }

    public func removeFavorite(movieId: MovieID) async throws {
        if let listIds = favoriteListsByMovie[movieId] {
            for listId in listIds {
                favoritesByList[listId]?.removeAll { $0.id == movieId }
            }
        }
        favoriteListsByMovie[movieId] = nil
        favoritesByListSubject.send(favoritesByList)
        favoriteListsByMovieSubject.send(favoriteListsByMovie)
    }

    public func favoriteListIds(movieId: MovieID) async throws -> Set<FavoriteListID> {
        favoriteListsByMovie[movieId] ?? []
    }

    public func favoriteListId(movieId: MovieID) async throws -> FavoriteListID? {
        if let listId = favoriteListsByMovie[movieId]?.first {
            return listId
        }
        return nil
    }

    public var favoriteListByMovie: [MovieID: FavoriteListID] {
        var map: [MovieID: FavoriteListID] = [:]
        for (movieId, listIds) in favoriteListsByMovie {
            if let listId = listIds.first {
                map[movieId] = listId
            }
        }
        return map
    }

    public var favoriteListByMovieSequence: any AsyncSequence<[MovieID: FavoriteListID], Never> {
        favoriteListsByMovieSubject.values.map { map in
            var singleMap: [MovieID: FavoriteListID] = [:]
            for (movieId, listIds) in map {
                if let listId = listIds.first {
                    singleMap[movieId] = listId
                }
            }
            return singleMap
        }
    }
}
