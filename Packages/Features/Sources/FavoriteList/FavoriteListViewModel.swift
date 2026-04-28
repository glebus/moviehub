import Foundation
import Observation
import DomainModels
import DomainUseCases
import Coordinator
import AuthButton

@MainActor
@Observable
public final class FavoriteListViewModel {
    public enum State: Sendable {
        case idle
        case loaded([FavoriteList])
        case error(String)
    }

    public var state: State {
        if currentUser == nil {
            return .idle
        }
        return .loaded(lists)
    }

    public var lists: [FavoriteList] = []
    public var currentUser: User?

    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let favoriteListsStateUseCase: FavoriteListsReader
    private let favoriteListsSequenceUseCase: FavoriteListsSequenceSource
    private let refreshFavoriteListsUseCase: RefreshFavoriteListsAction
    private let coordinator: any CoordinatorProtocol
    public let authButtonBuilder: AuthButtonBuilder

    @ObservationIgnored private var profileTask: Task<Void, Never>?
    @ObservationIgnored private var listsTask: Task<Void, Never>?

    init(
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        favoriteListsStateUseCase: @escaping FavoriteListsReader,
        favoriteListsSequenceUseCase: @escaping FavoriteListsSequenceSource,
        refreshFavoriteListsUseCase: @escaping RefreshFavoriteListsAction,
        coordinator: any CoordinatorProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.favoriteListsStateUseCase = favoriteListsStateUseCase
        self.favoriteListsSequenceUseCase = favoriteListsSequenceUseCase
        self.refreshFavoriteListsUseCase = refreshFavoriteListsUseCase
        self.coordinator = coordinator
        self.authButtonBuilder = authButtonBuilder
        self.lists = favoriteListsStateUseCase()
        self.currentUser = currentUserUseCase()
    }

    deinit {
        profileTask?.cancel()
        listsTask?.cancel()
    }

    public func onAppear() {
        subscribeToSession()
        subscribeToLists()
        Task { await refreshListsIfNeeded() }
    }

    public func select(listId: FavoriteListID) {
        coordinator.push(AppDestination.favoriteListDetails(listId))
    }

    private func subscribeToSession() {
        profileTask?.cancel()
        profileTask = Task { [weak self, currentUserSequenceUseCase] in
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
}
