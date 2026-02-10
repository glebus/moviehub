import Observation
import Domain
import Router
import AuthButton
import Utilities

@MainActor
@Observable
public final class FavoriteListPickerViewModel {
    public var lists: [FavoriteList]
    public var currentUser: User?
    public var errorMessage: String?

    private let movieDetails: MovieDetails
    private let sessionInteractor: SessionInteractorProtocol
    private let favoriteListsInteractor: FavoriteListsInteractorProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let router: AppRouterProtocol
    public let authButtonBuilder: AuthButtonBuilder

    @ObservationIgnored private var sessionTask: Task<Void, Never>?
    @ObservationIgnored private var listsTask: Task<Void, Never>?

    init(
        movieDetails: MovieDetails,
        sessionInteractor: SessionInteractorProtocol,
        favoriteListsInteractor: FavoriteListsInteractorProtocol,
        favoritesRepository: FavoritesRepositoryProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.movieDetails = movieDetails
        self.sessionInteractor = sessionInteractor
        self.favoriteListsInteractor = favoriteListsInteractor
        self.favoritesRepository = favoritesRepository
        self.router = router
        self.authButtonBuilder = authButtonBuilder
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

    public func select(listId: FavoriteListID) {
        Task { await addToList(listId: listId) }
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

    private func addToList(listId: FavoriteListID) async {
        guard let user = currentUser else {
            router.present(.auth)
            return
        }

        do {
            try await favoritesRepository.addFavorite(userId: user.id, movie: movieDetails, listId: listId)
            router.dismissSheet()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
