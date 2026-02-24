import Observation
import DomainModels
import DomainUseCases
import Router
import AuthButton

@MainActor
@Observable
public final class FavoriteListDetailsViewModel {
    public var listName: String
    public var listColor: FavoriteListColor
    public var favorites: [Movie]
    public var currentUser: User?
    public var errorMessage: String?

    private let listId: FavoriteListID
    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let favoriteListsStateUseCase: FavoriteListsReader
    private let favoriteListsSequenceUseCase: FavoriteListsSequenceSource
    private let refreshFavoriteListsUseCase: RefreshFavoriteListsAction
    private let favoritesByListStateUseCase: FavoritesByListReader
    private let favoritesByListSequenceUseCase: FavoritesByListSequenceSource
    private let refreshFavoritesUseCase: RefreshFavoritesAction
    private let router: AppRouterProtocol
    public let authButtonBuilder: AuthButtonBuilder

    @ObservationIgnored private var sessionTask: Task<Void, Never>?
    @ObservationIgnored private var listsTask: Task<Void, Never>?
    @ObservationIgnored private var favoritesTask: Task<Void, Never>?

    init(
        listId: FavoriteListID,
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        favoriteListsStateUseCase: @escaping FavoriteListsReader,
        favoriteListsSequenceUseCase: @escaping FavoriteListsSequenceSource,
        refreshFavoriteListsUseCase: @escaping RefreshFavoriteListsAction,
        favoritesByListStateUseCase: @escaping FavoritesByListReader,
        favoritesByListSequenceUseCase: @escaping FavoritesByListSequenceSource,
        refreshFavoritesUseCase: @escaping RefreshFavoritesAction,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.listId = listId
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.favoriteListsStateUseCase = favoriteListsStateUseCase
        self.favoriteListsSequenceUseCase = favoriteListsSequenceUseCase
        self.refreshFavoriteListsUseCase = refreshFavoriteListsUseCase
        self.favoritesByListStateUseCase = favoritesByListStateUseCase
        self.favoritesByListSequenceUseCase = favoritesByListSequenceUseCase
        self.refreshFavoritesUseCase = refreshFavoritesUseCase
        self.router = router
        self.authButtonBuilder = authButtonBuilder
        self.listName = "List"
        self.listColor = .slate
        self.favorites = favoritesByListStateUseCase()[listId] ?? []
        self.errorMessage = nil
        applySession(currentUserUseCase())
        applyLists(favoriteListsStateUseCase())
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
            try? await refreshFavoriteListsUseCase()
            await refreshFavorites()
        }
    }

    public func select(movieId: MovieID) {
        router.push(.movieDetails(movieId))
    }

    private func subscribeToSession() {
        sessionTask?.cancel()
        sessionTask = Task { [weak self, currentUserSequenceUseCase] in
            for await user in currentUserSequenceUseCase() {
                guard !Task.isCancelled else { break }
                self?.applySession(user)
                await self?.refreshFavorites()
            }
        }
    }

    private func subscribeToLists() {
        listsTask?.cancel()
        listsTask = Task { [weak self, favoriteListsSequenceUseCase] in
            for await lists in favoriteListsSequenceUseCase() {
                guard !Task.isCancelled else { break }
                self?.applyLists(lists)
            }
        }
    }

    private func subscribeToFavorites() {
        favoritesTask?.cancel()
        let listId = self.listId
        favoritesTask = Task { [weak self, favoritesByListSequenceUseCase] in
            for await favoritesByList in favoritesByListSequenceUseCase() {
                guard !Task.isCancelled else { break }
                self?.favorites = favoritesByList[listId] ?? []
            }
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
            try await refreshFavoritesUseCase(listId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
