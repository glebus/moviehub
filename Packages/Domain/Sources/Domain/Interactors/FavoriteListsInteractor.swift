import Foundation
import Observation
import Utilities

@MainActor
@Observable
public final class FavoriteListsInteractor: FavoriteListsInteractorProtocol {
    private let listsRepository: FavoriteListsRepositoryProtocol
    private let sessionInteractor: SessionInteractorProtocol
    public private(set) var lists: [FavoriteList]
    @ObservationIgnored private var sessionTask: Task<Void, Never>?

    public init(
        listsRepository: FavoriteListsRepositoryProtocol,
        sessionInteractor: SessionInteractorProtocol
    ) {
        self.listsRepository = listsRepository
        self.sessionInteractor = sessionInteractor
        self.lists = []
        observeSession()
    }

    deinit {
        sessionTask?.cancel()
    }

    public func refresh() async throws {
        let user = try requireUser()
        lists = try await listsRepository.fetchLists(userId: user.id)
    }

    public func create(name: String, color: FavoriteListColor) async throws -> FavoriteList {
        let user = try requireUser()
        let created = try await listsRepository.createList(userId: user.id, name: name, color: color)
        lists.append(created)
        return created
    }

    public func rename(listId: FavoriteListID, name: String) async throws {
        let user = try requireUser()
        try await listsRepository.renameList(userId: user.id, listId: listId, name: name)
        if let index = lists.firstIndex(where: { $0.id == listId }) {
            let updated = FavoriteList(
                id: lists[index].id,
                name: name,
                color: lists[index].color,
                createdAt: lists[index].createdAt
            )
            lists[index] = updated
        }
    }

    public func delete(listId: FavoriteListID) async throws {
        let user = try requireUser()
        try await listsRepository.deleteList(userId: user.id, listId: listId)
        lists.removeAll { $0.id == listId }
    }

    private func requireUser() throws -> User {
        guard let user = sessionInteractor.currentUser else {
            throw AuthRequiredError()
        }
        return user
    }

    private func observeSession() {
        sessionTask = observeChanges({ [sessionInteractor] in sessionInteractor.currentUser }) { [weak self] user in
            await self?.handleSessionChange(user)
        }
    }

    func handleSessionChange(_ user: User?) async {
        if user == nil {
            lists = []
        } else {
            try? await refresh()
        }
    }
}
