import Foundation
import Observation
import DomainModels
import DomainUseCases
import Router
import AuthButton

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
    private let movieDetailsUseCase: MovieDetailsAction
    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let favoriteListsStateUseCase: FavoriteListsReader
    private let favoriteListsSequenceUseCase: FavoriteListsSequenceSource
    private let favoriteListByMovieStateUseCase: FavoriteListByMovieReader
    private let favoriteListByMovieSequenceUseCase: FavoriteListByMovieSequenceSource
    private let removeFavoriteUseCase: RemoveFavoriteAction
    private let lookupFavoriteListUseCase: LookupFavoriteListAction
    private let router: AppRouterProtocol
    public let authButtonBuilder: AuthButtonBuilder

    @ObservationIgnored nonisolated(unsafe) private var sessionTask: Task<Void, Never>?
    @ObservationIgnored nonisolated(unsafe) private var listsTask: Task<Void, Never>?
    @ObservationIgnored nonisolated(unsafe) private var favoritesTask: Task<Void, Never>?
    private var currentUser: User?
    private var movieDetails: MovieDetails?
    private var lists: [FavoriteList] = []

    init(
        movieId: MovieID,
        movieDetailsUseCase: @escaping MovieDetailsAction,
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        favoriteListsStateUseCase: @escaping FavoriteListsReader,
        favoriteListsSequenceUseCase: @escaping FavoriteListsSequenceSource,
        favoriteListByMovieStateUseCase: @escaping FavoriteListByMovieReader,
        favoriteListByMovieSequenceUseCase: @escaping FavoriteListByMovieSequenceSource,
        removeFavoriteUseCase: @escaping RemoveFavoriteAction,
        lookupFavoriteListUseCase: @escaping LookupFavoriteListAction,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.movieId = movieId
        self.movieDetailsUseCase = movieDetailsUseCase
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.favoriteListsStateUseCase = favoriteListsStateUseCase
        self.favoriteListsSequenceUseCase = favoriteListsSequenceUseCase
        self.favoriteListByMovieStateUseCase = favoriteListByMovieStateUseCase
        self.favoriteListByMovieSequenceUseCase = favoriteListByMovieSequenceUseCase
        self.removeFavoriteUseCase = removeFavoriteUseCase
        self.lookupFavoriteListUseCase = lookupFavoriteListUseCase
        self.router = router
        self.authButtonBuilder = authButtonBuilder
        self.state = .idle
        self.isFavorite = false
        self.favoriteButtonEnabled = false
        self.favoriteButtonTitle = "Add to favorites"
        self.errorMessage = nil
        self.lists = favoriteListsStateUseCase()
        applySession(currentUserUseCase())
        subscribeToSession()
        subscribeToLists()
        subscribeToFavoriteUpdates()
    }

    deinit {
        sessionTask?.cancel()
        listsTask?.cancel()
        favoritesTask?.cancel()
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
            let details = try await movieDetailsUseCase(movieId)
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
        sessionTask?.cancel()
        sessionTask = Task { [weak self, currentUserSequenceUseCase] in
            for await user in currentUserSequenceUseCase() {
                guard !Task.isCancelled else { break }
                self?.applySession(user)
            }
        }
    }

    private func subscribeToLists() {
        listsTask?.cancel()
        listsTask = Task { [weak self, favoriteListsSequenceUseCase] in
            for await lists in favoriteListsSequenceUseCase() {
                guard !Task.isCancelled else { break }
                self?.lists = lists
            }
        }
    }

    private func subscribeToFavoriteUpdates() {
        favoritesTask?.cancel()
        favoritesTask = Task { [weak self, favoriteListByMovieSequenceUseCase] in
            for await map in favoriteListByMovieSequenceUseCase() {
                guard !Task.isCancelled else { break }
                guard let details = self?.movieDetails else { continue }
                self?.isFavorite = map[details.id] != nil
                self?.updateFavoriteButtonTitle()
            }
        }
    }

    private func applySession(_ user: User?) {
        currentUser = user
        favoriteButtonEnabled = user != nil
        Task { await refreshFavoriteStatus() }
    }

    func toggleFavorite() async {
        guard let details = movieDetails else { return }
        guard currentUser != nil else {
            router.present(.auth)
            return
        }

        do {
            if isFavorite {
                try await removeFavoriteUseCase(details.id)
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
        guard let details = movieDetails, currentUser != nil else {
            isFavorite = false
            updateFavoriteButtonTitle()
            return
        }
        do {
            let listId = try await lookupFavoriteListUseCase(details.id)
            isFavorite = listId != nil
        } catch {
            isFavorite = false
        }
        updateFavoriteButtonTitle()
    }
}
