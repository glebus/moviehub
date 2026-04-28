import Observation
import DomainModels
import DomainUseCases
import Coordinator

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
    private let refreshFavoritesUseCase: RefreshFavoritesAction
    private let addFavoriteUseCase: AddFavoriteAction
    private let removeFavoriteFromListUseCase: RemoveFavoriteFromListAction
    private let coordinator: any CoordinatorProtocol

    @ObservationIgnored private var didAppear = false

    private var favoriteMovieIds: Set<MovieID>
    private var inFlightMovieIds: Set<MovieID>

    init(
        request: FavoriteListAddMoviesRequest,
        searchMoviesUseCase: @escaping SearchMoviesAction,
        movieDetailsUseCase: @escaping MovieDetailsAction,
        refreshFavoritesUseCase: @escaping RefreshFavoritesAction,
        addFavoriteUseCase: @escaping AddFavoriteAction,
        removeFavoriteFromListUseCase: @escaping RemoveFavoriteFromListAction,
        coordinator: any CoordinatorProtocol
    ) {
        self.listId = request.listId
        self.listName = request.listName
        self.searchText = request.initialQuery
        self.searchResults = []
        self.isSearching = false
        self.errorMessage = nil
        self.searchMoviesUseCase = searchMoviesUseCase
        self.movieDetailsUseCase = movieDetailsUseCase
        self.refreshFavoritesUseCase = refreshFavoritesUseCase
        self.addFavoriteUseCase = addFavoriteUseCase
        self.removeFavoriteFromListUseCase = removeFavoriteFromListUseCase
        self.coordinator = coordinator
        self.favoriteMovieIds = []
        self.inFlightMovieIds = []
    }

    public func onAppear() {
        guard !didAppear else { return }
        didAppear = true
        Task {
            await refreshFavorites()
            await search()
        }
    }

    public func submitSearch() {
        Task { await search() }
    }

    public func doneTapped() {
        coordinator.dismiss()
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

    private func refreshFavorites() async {
        do {
            let favorites = try await refreshFavoritesUseCase(listId)
            favoriteMovieIds = Set(favorites.map(\.id))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
