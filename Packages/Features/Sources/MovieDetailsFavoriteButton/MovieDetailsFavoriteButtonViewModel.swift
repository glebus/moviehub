import Observation
import DomainModels
import DomainUseCases
import Router

@MainActor
@Observable
final class MovieDetailsFavoriteButtonViewModel {
    var isEnabled: Bool
    var title: String
    var errorMessage: String?

    private let movieDetails: MovieDetails
    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let favoriteListByMovieStateUseCase: FavoriteListByMovieReader
    private let favoriteListByMovieSequenceUseCase: FavoriteListByMovieSequenceSource
    private let handleFavoriteTapUseCase: HandleMovieDetailsFavoriteTapAction
    private let lookupFavoriteListUseCase: LookupFavoriteListAction
    private let router: AppRouterProtocol

    @ObservationIgnored nonisolated(unsafe) private var sessionTask: Task<Void, Never>?
    @ObservationIgnored nonisolated(unsafe) private var favoritesTask: Task<Void, Never>?

    private var currentUser: User?
    private var isFavorite: Bool

    init(
        movieDetails: MovieDetails,
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        favoriteListByMovieStateUseCase: @escaping FavoriteListByMovieReader,
        favoriteListByMovieSequenceUseCase: @escaping FavoriteListByMovieSequenceSource,
        handleFavoriteTapUseCase: @escaping HandleMovieDetailsFavoriteTapAction,
        lookupFavoriteListUseCase: @escaping LookupFavoriteListAction,
        router: AppRouterProtocol
    ) {
        self.movieDetails = movieDetails
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.favoriteListByMovieStateUseCase = favoriteListByMovieStateUseCase
        self.favoriteListByMovieSequenceUseCase = favoriteListByMovieSequenceUseCase
        self.handleFavoriteTapUseCase = handleFavoriteTapUseCase
        self.lookupFavoriteListUseCase = lookupFavoriteListUseCase
        self.router = router
        self.isEnabled = false
        self.title = "Add to favorites"
        self.errorMessage = nil
        self.isFavorite = false
        applySession(currentUserUseCase())
        subscribeToSession()
        subscribeToFavoriteUpdates()
    }

    deinit {
        sessionTask?.cancel()
        favoritesTask?.cancel()
    }

    func tapped() {
        Task { await toggleFavorite() }
    }

    func toggleFavorite() async {
        guard currentUser != nil else {
            router.present(.auth)
            return
        }

        errorMessage = nil

        do {
            let result = try await handleFavoriteTapUseCase(movieDetails)

            switch result {
            case .requireAuth:
                router.present(.auth)
            case .showCreateList:
                router.present(.favoriteListCreate)
            case .showPicker(let movieDetails):
                router.present(.favoriteListPicker(movieDetails))
            case .removed:
                isFavorite = false
                updateTitle()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func subscribeToSession() {
        sessionTask?.cancel()
        sessionTask = Task { [weak self, currentUserSequenceUseCase] in
            for await user in currentUserSequenceUseCase() {
                guard !Task.isCancelled else { break }
                self?.applySession(user)
            }
        }
    }

    private func subscribeToFavoriteUpdates() {
        favoritesTask?.cancel()
        favoritesTask = Task { [weak self, movieId = movieDetails.id, favoriteListByMovieSequenceUseCase] in
            for await map in favoriteListByMovieSequenceUseCase() {
                guard !Task.isCancelled else { break }
                self?.isFavorite = map[movieId] != nil
                self?.updateTitle()
            }
        }
    }

    private func applySession(_ user: User?) {
        currentUser = user
        updateEnabled()
        Task { await refreshFavoriteStatus() }
    }

    private func refreshFavoriteStatus() async {
        guard currentUser != nil else {
            isFavorite = false
            updateTitle()
            return
        }

        do {
            let listId = try await lookupFavoriteListUseCase(movieDetails.id)
            isFavorite = listId != nil
        } catch {
            isFavorite = false
        }

        updateTitle()
    }

    private func updateEnabled() {
        isEnabled = currentUser != nil
    }

    private func updateTitle() {
        title = isFavorite ? "Remove from favorites" : "Add to favorites"
    }
}
