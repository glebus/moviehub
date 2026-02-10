import Observation
import Domain
import Router
import Utilities

@MainActor
@Observable
public final class FavoriteListsManageViewModel {
    public var lists: [FavoriteList]
    public var currentUser: User?
    public var errorMessage: String?

    private let sessionInteractor: SessionInteractorProtocol
    private let favoriteListsInteractor: FavoriteListsInteractorProtocol
    private let router: AppRouterProtocol

    @ObservationIgnored private var sessionTask: Task<Void, Never>?
    @ObservationIgnored private var listsTask: Task<Void, Never>?

    init(
        sessionInteractor: SessionInteractorProtocol,
        favoriteListsInteractor: FavoriteListsInteractorProtocol,
        router: AppRouterProtocol
    ) {
        self.sessionInteractor = sessionInteractor
        self.favoriteListsInteractor = favoriteListsInteractor
        self.router = router
        self.lists = favoriteListsInteractor.lists
        self.currentUser = sessionInteractor.currentUser
        self.errorMessage = nil
    }

    deinit {
        sessionTask?.cancel()
        listsTask?.cancel()
    }

    public func onAppear() {
        subscribeToSession()
        subscribeToLists()
        Task { await refreshListsIfNeeded() }
    }

    public func addTapped() {
        router.present(.favoriteListCreate)
    }

    public func rename(listId: FavoriteListID, name: String) {
        Task { await renameList(listId: listId, name: name) }
    }

    public func delete(listId: FavoriteListID) {
        Task { await deleteList(listId: listId) }
    }

    private func subscribeToSession() {
        sessionTask?.cancel()
        sessionTask = observeChanges({ [sessionInteractor] in sessionInteractor.currentUser }) { [weak self] user in
            self?.currentUser = user
        }
    }

    private func subscribeToLists() {
        listsTask?.cancel()
        listsTask = observeChanges({ [favoriteListsInteractor] in favoriteListsInteractor.lists }) { [weak self] lists in
            self?.lists = lists
        }
    }

    private func refreshListsIfNeeded() async {
        guard currentUser != nil else { return }
        try? await favoriteListsInteractor.refresh()
    }

    private func renameList(listId: FavoriteListID, name: String) async {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        do {
            try await favoriteListsInteractor.rename(listId: listId, name: name)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteList(listId: FavoriteListID) async {
        do {
            try await favoriteListsInteractor.delete(listId: listId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
