import Foundation
import Observation
import Domain
import Router

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
    private let favoritesInteractor: FavoritesInteractorProtocol
    private let router: AppRouterProtocol

    @ObservationIgnored nonisolated(unsafe) private var sessionTask: Task<Void, Never>?
    @ObservationIgnored nonisolated(unsafe) private var favoritesTask: Task<Void, Never>?
    private var currentUser: User?
    private var movieDetails: MovieDetails?

    init(
        movieId: MovieID,
        movieRepository: MovieRepositoryProtocol,
        sessionInteractor: SessionInteractorProtocol,
        favoritesInteractor: FavoritesInteractorProtocol,
        router: AppRouterProtocol
    ) {
        self.movieId = movieId
        self.movieRepository = movieRepository
        self.sessionInteractor = sessionInteractor
        self.favoritesInteractor = favoritesInteractor
        self.router = router
        self.state = .idle
        self.isFavorite = false
        self.favoriteButtonEnabled = false
        self.favoriteButtonTitle = "Add to favorites"
        self.errorMessage = nil
        subscribeToSession()
        subscribeToFavorites()
    }

    deinit {
        sessionTask?.cancel()
        favoritesTask?.cancel()
    }

    public func onAppear() {
        Task { await loadDetails() }
    }

    public func favoriteButtonTapped() {
        Task { await toggleFavorite() }
    }

    private func loadDetails() async {
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
            isFavorite = favoritesInteractor.isFavorite(movieId: details.id)
            updateFavoriteButtonTitle()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private func subscribeToSession() {
        sessionTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await user in sessionInteractor.currentUserStream {
                self.currentUser = user
                self.favoriteButtonEnabled = user != nil
            }
        }
    }

    private func subscribeToFavorites() {
        favoritesTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await favorites in favoritesInteractor.favoritesStream {
                if let details = movieDetails {
                    self.isFavorite = favorites.contains { $0.id == details.id }
                    self.updateFavoriteButtonTitle()
                }
            }
        }
    }

    private func toggleFavorite() async {
        guard let details = movieDetails else { return }
        guard currentUser != nil else {
            router.navigate(.auth)
            return
        }

        do {
            let newValue = try await favoritesInteractor.toggle(movie: details)
            isFavorite = newValue
            updateFavoriteButtonTitle()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func updateFavoriteButtonTitle() {
        favoriteButtonTitle = isFavorite ? "Remove from favorites" : "Add to favorites"
    }
}
