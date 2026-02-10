import Foundation
import Observation
import Domain
import Router
import AuthButton
import Utilities

@MainActor
@Observable
public final class MovieDetailsViewModel {
    public enum State: Sendable {
        case idle
        case loading
        case loaded(MovieDetailsPresentationModel)
        case error(String)
    }

    public var state: State
    public var isFavorite: Bool
    public var favoriteButtonEnabled: Bool
    public var favoriteButtonTitle: String
    public var errorMessage: String?

    private let movieId: MovieID
    private let movieRepository: MovieRepositoryProtocol
    private let sessionInteractor: SessionInteractorProtocol
    private let favoriteListsInteractor: FavoriteListsInteractorProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let router: AppRouterProtocol
    public let authButtonBuilder: AuthButtonBuilder

    @ObservationIgnored nonisolated(unsafe) private var sessionTask: Task<Void, Never>?
    @ObservationIgnored nonisolated(unsafe) private var listsTask: Task<Void, Never>?
    private var currentUser: User?
    private var movieDetails: MovieDetails?
    private var lists: [FavoriteList] = []

    init(
        movieId: MovieID,
        movieRepository: MovieRepositoryProtocol,
        sessionInteractor: SessionInteractorProtocol,
        favoriteListsInteractor: FavoriteListsInteractorProtocol,
        favoritesRepository: FavoritesRepositoryProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.movieId = movieId
        self.movieRepository = movieRepository
        self.sessionInteractor = sessionInteractor
        self.favoriteListsInteractor = favoriteListsInteractor
        self.favoritesRepository = favoritesRepository
        self.router = router
        self.authButtonBuilder = authButtonBuilder
        self.state = .idle
        self.isFavorite = false
        self.favoriteButtonEnabled = false
        self.favoriteButtonTitle = "Add to favorites"
        self.errorMessage = nil
        self.lists = favoriteListsInteractor.lists
        applySession(sessionInteractor.currentUser)
        subscribeToSession()
        subscribeToLists()
    }

    deinit {
        sessionTask?.cancel()
        listsTask?.cancel()
    }

    public func onAppear() {
        if movieDetails == nil {
            Task { await loadDetails() }
        } else {
            Task { await refreshFavoriteStatus() }
        }
    }

    public func favoriteButtonTapped() {
        Task { await toggleFavorite() }
    }

    func loadDetails() async {
        state = .loading
        errorMessage = nil
        do {
            let details = try await movieRepository.details(id: movieId)
            movieDetails = details
            let presentation = MovieDetailsPresentationModel(
                id: details.id,
                title: details.title,
                posterURL: details.posterURL,
                overview: details.overview,
                genresText: details.genres.joined(separator: ", ")
            )
            state = .loaded(presentation)
            await refreshFavoriteStatus()
            updateFavoriteButtonTitle()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private func subscribeToSession() {
        sessionTask = observeChanges({ [sessionInteractor] in sessionInteractor.currentUser }) { [weak self] user in
            self?.applySession(user)
        }
    }

    private func subscribeToLists() {
        listsTask = observeChanges({ [favoriteListsInteractor] in favoriteListsInteractor.lists }) { [weak self] lists in
            self?.lists = lists
        }
    }

    private func applySession(_ user: User?) {
        currentUser = user
        favoriteButtonEnabled = user != nil
        Task { await refreshFavoriteStatus() }
    }

    func toggleFavorite() async {
        guard let details = movieDetails else { return }
        guard let user = currentUser else {
            router.present(.auth)
            return
        }

        do {
            if isFavorite {
                try await favoritesRepository.removeFavorite(userId: user.id, movieId: details.id)
                isFavorite = false
                updateFavoriteButtonTitle()
                return
            }

            if lists.isEmpty {
                router.present(.favoriteListCreate)
            } else {
                router.present(.favoriteListPicker(details))
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func updateFavoriteButtonTitle() {
        favoriteButtonTitle = isFavorite ? "Remove from favorites" : "Add to favorites"
    }

    private func refreshFavoriteStatus() async {
        guard let details = movieDetails, let user = currentUser else {
            isFavorite = false
            updateFavoriteButtonTitle()
            return
        }
        do {
            let listId = try await favoritesRepository.favoriteListId(userId: user.id, movieId: details.id)
            isFavorite = listId != nil
        } catch {
            isFavorite = false
        }
        updateFavoriteButtonTitle()
    }
}
