import Observation
import DomainModels
import DomainUseCases
import Coordinator

@MainActor
@Observable
public final class FavoriteListsManageViewModel {
    public var lists: [FavoriteList]
    public var currentUser: User?
    public var errorMessage: String?

    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let favoriteListsStateUseCase: FavoriteListsReader
    private let favoriteListsSequenceUseCase: FavoriteListsSequenceSource
    private let refreshFavoriteListsUseCase: RefreshFavoriteListsAction
    private let renameFavoriteListUseCase: RenameFavoriteListAction
    private let deleteFavoriteListUseCase: DeleteFavoriteListAction
    private let coordinator: any CoordinatorProtocol

    @ObservationIgnored private var sessionTask: Task<Void, Never>?
    @ObservationIgnored private var listsTask: Task<Void, Never>?

    init(
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        favoriteListsStateUseCase: @escaping FavoriteListsReader,
        favoriteListsSequenceUseCase: @escaping FavoriteListsSequenceSource,
        refreshFavoriteListsUseCase: @escaping RefreshFavoriteListsAction,
        renameFavoriteListUseCase: @escaping RenameFavoriteListAction,
        deleteFavoriteListUseCase: @escaping DeleteFavoriteListAction,
        coordinator: any CoordinatorProtocol
    ) {
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.favoriteListsStateUseCase = favoriteListsStateUseCase
        self.favoriteListsSequenceUseCase = favoriteListsSequenceUseCase
        self.refreshFavoriteListsUseCase = refreshFavoriteListsUseCase
        self.renameFavoriteListUseCase = renameFavoriteListUseCase
        self.deleteFavoriteListUseCase = deleteFavoriteListUseCase
        self.coordinator = coordinator
        self.lists = favoriteListsStateUseCase()
        self.currentUser = currentUserUseCase()
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
        coordinator.present(.favoriteListCreate(movieToAdd: nil))
    }

    public func rename(listId: FavoriteListID, name: String) {
        Task { await renameList(listId: listId, name: name) }
    }

    public func delete(listId: FavoriteListID) {
        Task { await deleteList(listId: listId) }
    }

    private func subscribeToSession() {
        sessionTask?.cancel()
        sessionTask = Task { [weak self, currentUserSequenceUseCase] in
            for await user in currentUserSequenceUseCase() {
                guard !Task.isCancelled else { break }
                self?.currentUser = user
            }
        }
    }

    private func subscribeToLists() {
        listsTask?.cancel()
        listsTask = Task { [weak self, favoriteListsSequenceUseCase] in
            for await lists in favoriteListsSequenceUseCase() {
                guard !Task.isCancelled else { break }
                self?.lists = lists
            }
        }
    }

    private func refreshListsIfNeeded() async {
        guard currentUser != nil else { return }
        try? await refreshFavoriteListsUseCase()
    }

    private func renameList(listId: FavoriteListID, name: String) async {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        do {
            try await renameFavoriteListUseCase(listId, name)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteList(listId: FavoriteListID) async {
        do {
            try await deleteFavoriteListUseCase(listId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
