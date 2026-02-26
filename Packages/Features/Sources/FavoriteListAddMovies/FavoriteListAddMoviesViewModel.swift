import Observation
import DomainModels
import DomainUseCases
import Router

@MainActor
@Observable
public final class FavoriteListAddMoviesViewModel {
    public var searchText: String
    public var searchResults: [Movie]
    public var isSearching: Bool
    public var errorMessage: String?

    let listId: FavoriteListID
    let listName: String

    private let searchMoviesUseCase: SearchMoviesAction
    private let movieDetailsUseCase: MovieDetailsAction
    private let favoritesByListStateUseCase: FavoritesByListReader
    private let favoritesByListSequenceUseCase: FavoritesByListSequenceSource
    private let refreshFavoritesUseCase: RefreshFavoritesAction
    private let addFavoriteUseCase: AddFavoriteAction
    private let removeFavoriteFromListUseCase: RemoveFavoriteFromListAction
    private let router: AppRouterProtocol

    @ObservationIgnored private var favoritesTask: Task<Void, Never>?
    @ObservationIgnored private var didAppear = false

    private var favoriteMovieIds: Set<MovieID>
    private var inFlightMovieIds: Set<MovieID>

    init(
        request: FavoriteListAddMoviesRequest,
        searchMoviesUseCase: @escaping SearchMoviesAction,
        movieDetailsUseCase: @escaping MovieDetailsAction,
        favoritesByListStateUseCase: @escaping FavoritesByListReader,
        favoritesByListSequenceUseCase: @escaping FavoritesByListSequenceSource,
        refreshFavoritesUseCase: @escaping RefreshFavoritesAction,
        addFavoriteUseCase: @escaping AddFavoriteAction,
        removeFavoriteFromListUseCase: @escaping RemoveFavoriteFromListAction,
        router: AppRouterProtocol
    ) {
        self.listId = request.listId
        self.listName = request.listName
        self.searchText = request.initialQuery
        self.searchResults = []
        self.isSearching = false
        self.errorMessage = nil
        self.searchMoviesUseCase = searchMoviesUseCase
        self.movieDetailsUseCase = movieDetailsUseCase
        self.favoritesByListStateUseCase = favoritesByListStateUseCase
        self.favoritesByListSequenceUseCase = favoritesByListSequenceUseCase
        self.refreshFavoritesUseCase = refreshFavoritesUseCase
        self.addFavoriteUseCase = addFavoriteUseCase
        self.removeFavoriteFromListUseCase = removeFavoriteFromListUseCase
        self.router = router
        self.favoriteMovieIds = Set((favoritesByListStateUseCase()[request.listId] ?? []).map(\.id))
        self.inFlightMovieIds = []
    }

    deinit {
        favoritesTask?.cancel()
    }

    public func onAppear() {
        guard !didAppear else { return }
        didAppear = true
        subscribeToFavorites()
        Task {
            try? await refreshFavoritesUseCase(listId)
            await search()
        }
    }

    public func submitSearch() {
        Task { await search() }
    }

    public func doneTapped() {
        router.dismissSheet()
    }

    public func isSelected(movieId: MovieID) -> Bool {
        favoriteMovieIds.contains(movieId)
    }

    public func isUpdating(movieId: MovieID) -> Bool {
        inFlightMovieIds.contains(movieId)
    }

    public func toggle(movieId: MovieID, isOn: Bool) {
        guard let movie = searchResults.first(where: { $0.id == movieId }) else { return }
        guard !inFlightMovieIds.contains(movieId) else { return }
        Task { await setFavorite(movie: movie, isOn: isOn) }
    }

    private func subscribeToFavorites() {
        favoritesTask?.cancel()
        let listId = self.listId
        favoritesTask = Task { [weak self, favoritesByListSequenceUseCase] in
            for await favoritesByList in favoritesByListSequenceUseCase() {
                guard !Task.isCancelled else { break }
                let ids = Set((favoritesByList[listId] ?? []).map(\.id))
                self?.favoriteMovieIds = ids
            }
        }
    }

    private func search() async {
        isSearching = true
        defer { isSearching = false }
        do {
            searchResults = try await searchMoviesUseCase(searchText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func setFavorite(movie: Movie, isOn: Bool) async {
        inFlightMovieIds.insert(movie.id)
        defer { inFlightMovieIds.remove(movie.id) }

        do {
            if isOn {
                let details = try await movieDetailsUseCase(movie.id)
                try await addFavoriteUseCase(details, listId)
                favoriteMovieIds.insert(movie.id)
            } else {
                try await removeFavoriteFromListUseCase(movie.id, listId)
                favoriteMovieIds.remove(movie.id)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
