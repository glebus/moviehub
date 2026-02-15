import Observation
import Domain
import Router
import AuthButton
import Utilities

@MainActor
@Observable
public final class FavoriteListDetailsViewModel {
    public var listName: String
    public var listColor: FavoriteListColor
    public var favorites: [Movie]
    public var currentUser: User?
    public var errorMessage: String?

    private let listId: FavoriteListID
    private let sessionInteractor: SessionInteractorProtocol
    private let favoriteListsInteractor: FavoriteListsInteractorProtocol
    private let favoritesInteractor: FavoritesInteractorProtocol
    private let router: AppRouterProtocol
    public let authButtonBuilder: AuthButtonBuilder

    @ObservationIgnored private var sessionTask: Task<Void, Never>?
    @ObservationIgnored private var listsTask: Task<Void, Never>?
    @ObservationIgnored private var favoritesTask: Task<Void, Never>?

    init(
        listId: FavoriteListID,
        sessionInteractor: SessionInteractorProtocol,
        favoriteListsInteractor: FavoriteListsInteractorProtocol,
        favoritesInteractor: FavoritesInteractorProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.listId = listId
        self.sessionInteractor = sessionInteractor
        self.favoriteListsInteractor = favoriteListsInteractor
        self.favoritesInteractor = favoritesInteractor
        self.router = router
        self.authButtonBuilder = authButtonBuilder
        self.listName = "List"
        self.listColor = .slate
        self.favorites = favoritesInteractor.favoritesByList[listId] ?? []
        self.errorMessage = nil
        applySession(sessionInteractor.currentUser)
        applyLists(favoriteListsInteractor.lists)
    }

    deinit {
        sessionTask?.cancel()
        listsTask?.cancel()
        favoritesTask?.cancel()
    }

    public func onAppear() {
        subscribeToSession()
        subscribeToLists()
        subscribeToFavorites()
        Task {
            try? await favoriteListsInteractor.refresh()
            await refreshFavorites()
        }
    }

    public func select(movieId: MovieID) {
        router.push(.movieDetails(movieId))
    }

    private func subscribeToSession() {
        sessionTask?.cancel()
        sessionTask = observeChanges({ [sessionInteractor] in sessionInteractor.currentUser }) { [weak self] user in
            self?.applySession(user)
            await self?.refreshFavorites()
        }
    }

    private func subscribeToLists() {
        listsTask?.cancel()
        listsTask = observeChanges({ [favoriteListsInteractor] in favoriteListsInteractor.lists }) { [weak self] lists in
            self?.applyLists(lists)
        }
    }

    private func subscribeToFavorites() {
        favoritesTask?.cancel()
        let listId = self.listId
        favoritesTask = observeChanges({ [favoritesInteractor] in favoritesInteractor.favoritesByList }) { [weak self] favoritesByList in
            self?.favorites = favoritesByList[listId] ?? []
        }
    }

    private func applySession(_ user: User?) {
        currentUser = user
        if user == nil {
            favorites = []
        }
    }

    private func applyLists(_ lists: [FavoriteList]) {
        if let list = lists.first(where: { $0.id == listId }) {
            listName = list.name
            listColor = list.color
        }
    }

    private func refreshFavorites() async {
        do {
            try await favoritesInteractor.refreshFavorites(listId: listId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
