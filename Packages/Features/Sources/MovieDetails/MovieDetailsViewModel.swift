import Foundation
import Observation
import Domain

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
    public var isAuthSheetPresented: Bool
    public var errorMessage: String?

    private let movieId: MovieID
    private let movieRepository: MovieRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol

    @ObservationIgnored nonisolated(unsafe) private var profileTask: Task<Void, Never>?
    private var currentUser: User?
    private var movieDetails: MovieDetails?

    public init(
        movieId: MovieID,
        movieRepository: MovieRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol,
        favoritesRepository: FavoritesRepositoryProtocol,
        toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol
    ) {
        self.movieId = movieId
        self.movieRepository = movieRepository
        self.profileRepository = profileRepository
        self.favoritesRepository = favoritesRepository
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.state = .idle
        self.isFavorite = false
        self.favoriteButtonEnabled = false
        self.favoriteButtonTitle = "Add to favorites"
        self.isAuthSheetPresented = false
        self.errorMessage = nil
        subscribeToProfile()
    }

    deinit {
        profileTask?.cancel()
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
            await refreshFavoriteState()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private func subscribeToProfile() {
        profileTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await user in profileRepository.currentUserStream {
                self.currentUser = user
                self.favoriteButtonEnabled = user != nil
                await refreshFavoriteState()
            }
        }
    }

    private func refreshFavoriteState() async {
        guard let details = movieDetails else { return }
        guard let user = currentUser else {
            isFavorite = false
            updateFavoriteButtonTitle()
            return
        }

        do {
            let favorite = try await favoritesRepository.isFavorite(movieId: details.id, userId: user.id)
            isFavorite = favorite
        } catch {
            errorMessage = error.localizedDescription
        }
        updateFavoriteButtonTitle()
    }

    private func toggleFavorite() async {
        guard let details = movieDetails else { return }
        guard currentUser != nil else {
            isAuthSheetPresented = true
            return
        }

        do {
            let newValue = try await toggleFavoriteUseCase.toggle(movie: details)
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
