import Foundation
import Domain

@MainActor
public final class FavoritesRepository: FavoritesRepositoryProtocol {
    private let storage: FavoritesStorageProtocol
    private let subjects = FavoritesSubjectStore()

    public init(storage: FavoritesStorageProtocol) {
        self.storage = storage
    }

    public func favorites(userId: UserID) async throws -> [Movie] {
        try await storage.fetchFavorites(userId: userId)
    }

    public func favoritesStream(userId: UserID) -> AsyncStream<[Movie]> {
        let subject = subjects.subject(for: userId)
        if subjects.shouldInitialize(for: userId) {
            Task {
                let current = try await storage.fetchFavorites(userId: userId)
                await subject.send(current)
            }
        }
        return subject.stream()
    }

    public func isFavorite(movieId: MovieID, userId: UserID) async throws -> Bool {
        try await storage.existsFavorite(userId: userId, movieId: movieId)
    }

    public func add(movie: MovieDetails, userId: UserID) async throws {
        try await storage.addFavorite(userId: userId, movie: movie)
        let updated = try await storage.fetchFavorites(userId: userId)
        let subject = subjects.subject(for: userId)
        await subject.send(updated)
    }

    public func remove(movieId: MovieID, userId: UserID) async throws {
        try await storage.removeFavorite(userId: userId, movieId: movieId)
        let updated = try await storage.fetchFavorites(userId: userId)
        let subject = subjects.subject(for: userId)
        await subject.send(updated)
    }
}

@MainActor
private final class FavoritesSubjectStore {
    private struct State {
        var subjects: [UserID: AsyncStreamSubject<[Movie]>] = [:]
        var initialized: Set<UserID> = []
    }

    private var state = State()

    func subject(for userId: UserID) -> AsyncStreamSubject<[Movie]> {
        if let existing = state.subjects[userId] {
            return existing
        }
        let subject = AsyncStreamSubject<[Movie]>()
        state.subjects[userId] = subject
        return subject
    }

    func shouldInitialize(for userId: UserID) -> Bool {
        if state.initialized.contains(userId) {
            return false
        }
        state.initialized.insert(userId)
        return true
    }
}
