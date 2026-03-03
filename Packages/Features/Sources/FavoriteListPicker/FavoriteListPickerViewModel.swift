import Observation
import DomainModels
import DomainUseCases
import Coordinator
import AuthButton

@MainActor
@Observable
public final class FavoriteListPickerViewModel {
    public var lists: [FavoriteList]
    public var currentUser: User?
    public var errorMessage: String?

    private let movieDetails: MovieDetails
    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let favoriteListsStateUseCase: FavoriteListsReader
    private let favoriteListsSequenceUseCase: FavoriteListsSequenceSource
    private let refreshFavoriteListsUseCase: RefreshFavoriteListsAction
    private let addFavoriteUseCase: AddFavoriteAction
    private let coordinator: AppCoordinatorProtocol
    public let authButtonBuilder: AuthButtonBuilder

    @ObservationIgnored private var sessionTask: Task<Void, Never>?
    @ObservationIgnored private var listsTask: Task<Void, Never>?

    init(
        movieDetails: MovieDetails,
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        favoriteListsStateUseCase: @escaping FavoriteListsReader,
        favoriteListsSequenceUseCase: @escaping FavoriteListsSequenceSource,
        refreshFavoriteListsUseCase: @escaping RefreshFavoriteListsAction,
        addFavoriteUseCase: @escaping AddFavoriteAction,
        coordinator: AppCoordinatorProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.movieDetails = movieDetails
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.favoriteListsStateUseCase = favoriteListsStateUseCase
        self.favoriteListsSequenceUseCase = favoriteListsSequenceUseCase
        self.refreshFavoriteListsUseCase = refreshFavoriteListsUseCase
        self.addFavoriteUseCase = addFavoriteUseCase
        self.coordinator = coordinator
        self.authButtonBuilder = authButtonBuilder
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

    public func select(listId: FavoriteListID) {
        Task { await addToList(listId: listId) }
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

    private func addToList(listId: FavoriteListID) async {
        guard currentUser != nil else {
            coordinator.present(.auth)
            return
        }

        do {
            try await addFavoriteUseCase(movieDetails, listId)
            coordinator.dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
