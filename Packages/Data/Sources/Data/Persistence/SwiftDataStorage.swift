import Foundation
import SwiftData
import DomainModels

@MainActor
public final class SwiftDataStorage {
    private let container: ModelContainer
    private let context: ModelContext

    public init(container: ModelContainer) {
        self.container = container
        self.context = ModelContext(container)
    }

    public func findUser(username: String) async throws -> User? {
        let normalized = UsernameNormalizer.normalize(username)
        let descriptor = FetchDescriptor<SDUser>(predicate: #Predicate { $0.id == normalized })
        let results = try context.fetch(descriptor)
        return results.first.map(mapUser)
    }

    public func createUser(username: String) async throws -> User {
        let normalized = UsernameNormalizer.normalize(username)
        let descriptor = FetchDescriptor<SDUser>(predicate: #Predicate { $0.id == normalized })
        let results = try context.fetch(descriptor)
        if let existing = results.first {
            return mapUser(existing)
        }

        let user = SDUser(id: normalized, username: normalized, createdAt: Date())
        context.insert(user)
        try context.save()
        return mapUser(user)
    }

    public func fetchFavorites(userId: UserID, listId: FavoriteListID) async throws -> [Movie] {
        let descriptor = FetchDescriptor<SDFavorite>(
            predicate: #Predicate { $0.userId == userId.rawValue && $0.listId == listId.rawValue }
        )
        let results = try context.fetch(descriptor)
        return results.map(mapFavorite)
    }

    public func favoriteListId(userId: UserID, movieId: MovieID) async throws -> FavoriteListID? {
        let descriptor = FetchDescriptor<SDFavorite>(
            predicate: #Predicate { $0.userId == userId.rawValue && $0.movieId == movieId.rawValue }
        )
        let results = try context.fetch(descriptor)
        return results.first.map { FavoriteListID($0.listId) }
    }

    public func favoriteListIds(userId: UserID, movieId: MovieID) async throws -> Set<FavoriteListID> {
        let descriptor = FetchDescriptor<SDFavorite>(
            predicate: #Predicate { $0.userId == userId.rawValue && $0.movieId == movieId.rawValue }
        )
        let results = try context.fetch(descriptor)
        return Set(results.map { FavoriteListID($0.listId) })
    }

    public func addFavorite(userId: UserID, movie: MovieDetails, listId: FavoriteListID) async throws {
        let descriptor = FetchDescriptor<SDFavorite>(
            predicate: #Predicate {
                $0.userId == userId.rawValue &&
                $0.movieId == movie.id.rawValue &&
                $0.listId == listId.rawValue
            }
        )
        let results = try context.fetch(descriptor)
        if !results.isEmpty {
            return
        }

        let favorite = SDFavorite(
            userId: userId.rawValue,
            listId: listId.rawValue,
            movieId: movie.id.rawValue,
            title: movie.title,
            year: nil,
            posterURL: movie.posterURL?.absoluteString,
            createdAt: Date()
        )
        context.insert(favorite)
        try context.save()
    }

    public func removeFavorite(userId: UserID, movieId: MovieID, listId: FavoriteListID) async throws {
        let descriptor = FetchDescriptor<SDFavorite>(
            predicate: #Predicate {
                $0.userId == userId.rawValue &&
                $0.movieId == movieId.rawValue &&
                $0.listId == listId.rawValue
            }
        )
        let results = try context.fetch(descriptor)
        for item in results {
            context.delete(item)
        }
        if !results.isEmpty {
            try context.save()
        }
    }

    public func removeFavorite(userId: UserID, movieId: MovieID) async throws {
        let descriptor = FetchDescriptor<SDFavorite>(
            predicate: #Predicate { $0.userId == userId.rawValue && $0.movieId == movieId.rawValue }
        )
        let results = try context.fetch(descriptor)
        for item in results {
            context.delete(item)
        }
        if !results.isEmpty {
            try context.save()
        }
    }

    public func fetchLists(userId: UserID) async throws -> [FavoriteList] {
        let descriptor = FetchDescriptor<SDFavoriteList>(predicate: #Predicate { $0.userId == userId.rawValue })
        let results = try context.fetch(descriptor)
        return results.map(mapFavoriteList)
    }

    public func createList(userId: UserID, name: String, color: FavoriteListColor) async throws -> FavoriteList {
        let list = SDFavoriteList(
            id: UUID().uuidString,
            userId: userId.rawValue,
            name: name,
            colorRaw: color.rawValue,
            createdAt: Date()
        )
        context.insert(list)
        try context.save()
        return mapFavoriteList(list)
    }

    public func renameList(userId: UserID, listId: FavoriteListID, name: String) async throws {
        let descriptor = FetchDescriptor<SDFavoriteList>(
            predicate: #Predicate { $0.userId == userId.rawValue && $0.id == listId.rawValue }
        )
        let results = try context.fetch(descriptor)
        if let list = results.first {
            list.name = name
            try context.save()
        }
    }

    public func deleteList(userId: UserID, listId: FavoriteListID) async throws {
        let listDescriptor = FetchDescriptor<SDFavoriteList>(
            predicate: #Predicate { $0.userId == userId.rawValue && $0.id == listId.rawValue }
        )
        let listResults = try context.fetch(listDescriptor)
        for list in listResults {
            context.delete(list)
        }

        let favoritesDescriptor = FetchDescriptor<SDFavorite>(
            predicate: #Predicate { $0.userId == userId.rawValue && $0.listId == listId.rawValue }
        )
        let favoriteResults = try context.fetch(favoritesDescriptor)
        for favorite in favoriteResults {
            context.delete(favorite)
        }
        if !listResults.isEmpty || !favoriteResults.isEmpty {
            try context.save()
        }
    }

    private func mapUser(_ user: SDUser) -> User {
        User(id: UserID(user.id), username: user.username)
    }

    private func mapFavorite(_ favorite: SDFavorite) -> Movie {
        Movie(
            id: MovieID(favorite.movieId),
            title: favorite.title,
            year: favorite.year,
            posterURL: favorite.posterURL.flatMap(URL.init(string:))
        )
    }

    private func mapFavoriteList(_ list: SDFavoriteList) -> FavoriteList {
        FavoriteList(
            id: FavoriteListID(list.id),
            name: list.name,
            color: FavoriteListColor(rawValue: list.colorRaw) ?? .slate,
            createdAt: list.createdAt
        )
    }
}
