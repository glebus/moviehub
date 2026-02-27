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
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let handleFavoriteTapUseCase: HandleMovieDetailsFavoriteTapAction
    private let lookupCurrentUserFavoriteListsUseCase: LookupCurrentUserFavoriteListsAction
    private let router: AppRouterProtocol

    @ObservationIgnored nonisolated(unsafe) private var sessionTask: Task<Void, Never>?

    private var currentUser: User?
    private var isFavorite: Bool

    init(
        movieDetails: MovieDetails,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        handleFavoriteTapUseCase: @escaping HandleMovieDetailsFavoriteTapAction,
        lookupCurrentUserFavoriteListsUseCase: @escaping LookupCurrentUserFavoriteListsAction,
        router: AppRouterProtocol
    ) {
        self.movieDetails = movieDetails
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.handleFavoriteTapUseCase = handleFavoriteTapUseCase
        self.lookupCurrentUserFavoriteListsUseCase = lookupCurrentUserFavoriteListsUseCase
        self.router = router
        self.isEnabled = false
        self.title = "Add to favorites"
        self.errorMessage = nil
        self.isFavorite = false
        subscribeToSession()
        Task { await refreshFavoriteStatus() }
    }

    deinit {
        sessionTask?.cancel()
    }

    func tapped() {
        Task { await toggleFavorite() }
    }

    func toggleFavorite() async {
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

    private func applySession(_ user: User?) {
        currentUser = user
        updateEnabled()
        Task { await refreshFavoriteStatus() }
    }

    private func refreshFavoriteStatus() async {
        do {
            let result = try await lookupCurrentUserFavoriteListsUseCase(movieDetails.id)
            switch result {
            case .requireAuth:
                isEnabled = false
                isFavorite = false
            case .favoriteListIDs(let listIDs):
                isEnabled = true
                isFavorite = !listIDs.isEmpty
            }
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
