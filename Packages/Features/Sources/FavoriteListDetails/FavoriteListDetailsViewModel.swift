import Observation
import DomainModels
import DomainUseCases
import Coordinator

@MainActor
@Observable
public final class FavoriteListDetailsViewModel {
    public var listName: String
    public var listColor: FavoriteListColor
    public var favorites: [Movie]
    public var errorMessage: String?

    private let listId: FavoriteListID
    private let favoriteListsStateUseCase: FavoriteListsReader
    private let favoriteListsSequenceUseCase: FavoriteListsSequenceSource
    private let refreshFavoriteListsUseCase: RefreshFavoriteListsAction
    private let refreshFavoritesUseCase: RefreshFavoritesAction
    private let coordinator: any CoordinatorProtocol

    @ObservationIgnored private var listsTask: Task<Void, Never>?

    init(
        listId: FavoriteListID,
        favoriteListsStateUseCase: @escaping FavoriteListsReader,
        favoriteListsSequenceUseCase: @escaping FavoriteListsSequenceSource,
        refreshFavoriteListsUseCase: @escaping RefreshFavoriteListsAction,
        refreshFavoritesUseCase: @escaping RefreshFavoritesAction,
        coordinator: any CoordinatorProtocol
    ) {
        self.listId = listId
        self.favoriteListsStateUseCase = favoriteListsStateUseCase
        self.favoriteListsSequenceUseCase = favoriteListsSequenceUseCase
        self.refreshFavoriteListsUseCase = refreshFavoriteListsUseCase
        self.refreshFavoritesUseCase = refreshFavoritesUseCase
        self.coordinator = coordinator
        self.listName = "List"
        self.listColor = .slate
        self.favorites = []
        self.errorMessage = nil
        applyLists(favoriteListsStateUseCase())
    }

    deinit {
        listsTask?.cancel()
    }

    public func onAppear() {
        subscribeToLists()
        Task {
            try? await refreshFavoriteListsUseCase()
            await refreshFavorites()
        }
    }

    public func select(movieId: MovieID) {
        coordinator.push(AppDestination.movieDetails(movieId))
    }

    public func addMovieTapped() {
        coordinator.present(AppDestination.favoriteListAddMovies(FavoriteListAddMoviesRequest(
            listId: listId,
            listName: listName,
            initialQuery: "Spider-man"
        )))
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

    private func applyLists(_ lists: [FavoriteList]) {
        if let list = lists.first(where: { $0.id == listId }) {
            listName = list.name
            listColor = list.color
        }
    }

    private func refreshFavorites() async {
        do {
            favorites = try await refreshFavoritesUseCase(listId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
