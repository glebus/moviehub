import Foundation
import SwiftData
import Domain

public actor SwiftDataStorage: ProfileStorageProtocol, FavoritesStorageProtocol {
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

    public func fetchFavorites(userId: UserID) async throws -> [Movie] {
        let descriptor = FetchDescriptor<SDFavorite>(predicate: #Predicate { $0.userId == userId.rawValue })
        let results = try context.fetch(descriptor)
        return results.map(mapFavorite)
    }

    public func existsFavorite(userId: UserID, movieId: MovieID) async throws -> Bool {
        let descriptor = FetchDescriptor<SDFavorite>(predicate: #Predicate { $0.userId == userId.rawValue && $0.movieId == movieId.rawValue })
        let results = try context.fetch(descriptor)
        return results.first != nil
    }

    public func addFavorite(userId: UserID, movie: MovieDetails) async throws {
        let descriptor = FetchDescriptor<SDFavorite>(predicate: #Predicate { $0.userId == userId.rawValue && $0.movieId == movie.id.rawValue })
        let results = try context.fetch(descriptor)
        if results.first != nil {
            return
        }

        let favorite = SDFavorite(
            userId: userId.rawValue,
            movieId: movie.id.rawValue,
            title: movie.title,
            year: nil,
            posterURL: movie.posterURL?.absoluteString,
            createdAt: Date()
        )
        context.insert(favorite)
        try context.save()
    }

    public func removeFavorite(userId: UserID, movieId: MovieID) async throws {
        let descriptor = FetchDescriptor<SDFavorite>(predicate: #Predicate { $0.userId == userId.rawValue && $0.movieId == movieId.rawValue })
        let results = try context.fetch(descriptor)
        for item in results {
            context.delete(item)
        }
        if !results.isEmpty {
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
}
